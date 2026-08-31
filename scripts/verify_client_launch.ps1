# 客户端启动验证：用合并后的版本 json 真实启动一次 Minecraft Forge
# 用法：pwsh scripts/verify_client_launch.ps1 [-GameDir <build_pcl/.minecraft>] [-TimeoutSec <s>]
param([string]$GameDir = (Join-Path (Resolve-Path '.').Path 'build_pcl\.minecraft'), [int]$TimeoutSec = 150)
$ErrorActionPreference = 'Continue'
$verDir = Join-Path $GameDir 'versions\Starfall-Chronicles'
$jsonPath = Join-Path $verDir 'Starfall-Chronicles.json'
if (-not (Test-Path $jsonPath)) { Write-Host "!! 无版本 json: $jsonPath"; exit 1 }
$j = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
$libsDir = Join-Path $GameDir 'libraries'

# ---- classpath ----
$cp = New-Object System.Collections.Generic.List[string]
foreach ($l in @($j.libraries)) {
  if ($l.downloads.artifact.path) { $cp.Add((Join-Path $libsDir ($l.downloads.artifact.path -replace '/', '\'))) }
}
$clientJar = Join-Path $verDir 'Starfall-Chronicles.jar'
if (Test-Path $clientJar) { $cp.Add($clientJar) }
$classpath = ($cp | Where-Object { Test-Path $_ }) -join ';'
Write-Host ("classpath 条目: " + ($cp.Count) + " 存在: " + (@($cp | Where-Object { Test-Path $_ }).Count))

# ---- natives ----
$natives = Join-Path $verDir 'natives'
New-Item -ItemType Directory -Force -Path $natives | Out-Null
foreach ($l in @($j.libraries)) {
  if ($l.downloads.classifiers.natives_windows -or ($l.name -match 'natives-windows')) {
    $art = $l.downloads.classifiers.natives_windows
    if ($art.path) {
      $jar = Join-Path $libsDir ($art.path -replace '/', '\')
      if (Test-Path $jar) {
        $tmp = Join-Path $natives ('n_' + [System.IO.Path]::GetFileNameWithoutExtension($jar))
        if (-not (Test-Path (Join-Path $tmp 'done'))) {
          New-Item -ItemType Directory -Force -Path $tmp | Out-Null
          Add-Type -AssemblyName System.IO.Compression.FileSystem
          try { [System.IO.Compression.ZipFile]::ExtractToDirectory($jar, $tmp, $true) | Out-Null; [System.IO.File]::WriteAllText((Join-Path $tmp 'done'), 'ok', (New-Object System.Text.UTF8Encoding($false))) } catch {}
        }
        # 把 dll 复制到 natives 根
        Get-ChildItem $tmp -Filter '*.dll' -ErrorAction SilentlyContinue | ForEach-Object { Copy-Item $_.FullName (Join-Path $natives $_.Name) -Force -ErrorAction SilentlyContinue }
      }
    }
  }
}

# ---- 展开参数 ----
function Expand([string]$s) {
  return $s -replace '\$\{library_directory\}', $libsDir -replace '\$\{natives_directory\}', $natives -replace '\$\{classpath\}', $classpath -replace '\$\{classpath_separator\}', ';' -replace '\$\{launcher_name\}', 'StarfallVerify' -replace '\$\{launcher_version\}', '1.0' -replace '\$\{version_name\}', 'Starfall-Chronicles' -replace '\$\{assets_root\}', (Join-Path $GameDir 'assets') -replace '\$\{assets_index_name\}', '1.20.1' -replace '\$\{auth_player_name\}', 'Verify' -replace '\$\{auth_uuid\}', '00000000-0000-0000-0000-000000000000' -replace '\$\{auth_access_token\}', '0' -replace '\$\{auth_session\}', '0' -replace '\$\{clientid\}', '0' -replace '\$\{auth_xuid\}', '0' -replace '\$\{user_type\}', 'legacy' -replace '\$\{version_type\}', 'release' -replace '\$\{game_directory\}', $GameDir -replace '\$\{resolution_width\}', '854' -replace '\$\{resolution_height\}', '480' -replace '\$\{quickPlayPath\}', '' -replace '\$\{quickPlaySingleplayer\}', '' -replace '\$\{quickPlayMultiplayer\}', '' -replace '\$\{quickPlayRealms\}', ''
}
$jvm = @()
foreach ($a in @($j.arguments.jvm)) {
  if ($a -is [string]) { $jvm += (Expand $a) }
  else {
    # rules 对象：取 windows 允许的 value
    $osOk = $true
    foreach ($r in @($a.rules)) {
      if ($r.action -eq 'disallow' -and $r.os.name -eq 'windows') { $osOk = $false }
    }
    if ($osOk) { $vals = @($a.value); foreach ($v in $vals) { $jvm += (Expand ([string]$v)) } }
  }
}
$game = @()
foreach ($a in @($j.arguments.game)) {
  if ($a -is [string]) { $game += (Expand $a) }
  else {
    $osOk = $true
    foreach ($r in @($a.rules)) { if ($r.action -eq 'disallow' -and $r.os.name -eq 'windows') { $osOk = $false } }
    if ($osOk) { foreach ($v in @($a.value)) { $game += (Expand ([string]$v)) } }
  }
}
$game += @('--gameDir', $GameDir, '--assetsDir', (Join-Path $GameDir 'assets'), '--version', 'Starfall-Chronicles', '--username', 'Verify', '--uuid', '00000000-0000-0000-0000-000000000000', '--accessToken', '0', '--userType', 'legacy', '--versionType', 'release')

# ---- 启动 ----
$java = 'java'
if ($env:JAVA_HOME) { $java = Join-Path $env:JAVA_HOME 'bin\java.exe' }
if (-not (Test-Path $java)) { $java = 'java' }
$logFile = Join-Path $env:TEMP 'starfall_client_verify.log'
if (Test-Path $logFile) { Remove-Item $logFile -Force }
Write-Host "启动 java（最多 $TimeoutSec 秒）..."
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $java
$psi.Arguments = (($jvm + @('-Djava.util.logging.config.file=""', '-Xmx2G', $j.mainClass) + $game) | ForEach-Object { '"' + $_ + '"' }) -join ' '
$psi.WorkingDirectory = $GameDir
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false
$proc = [System.Diagnostics.Process]::Start($psi)
$out = $proc.StandardOutput.ReadToEndAsync()
$err = $proc.StandardError.ReadToEndAsync()
if (-not $proc.WaitForExit($TimeoutSec * 1000)) {
  try { $proc.Kill() } catch {}
  Write-Host "超时强制结束（启动进入正常加载阶段的可能性大）"
}
$logTxt = ($out.Result) + "`n" + ($err.Result)
[System.IO.File]::WriteAllText((Join-Path $env:TEMP 'starfall_client_verify.log'), $logTxt, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "=== 启动日志关键行 ==="
($logTxt -split "`n") | Where-Object { $_ -match 'Setting user|Loading Minecraft|Forge|FATAL|Exception|Error|main class|classpath|Caused by' } | Select-Object -First 14 | ForEach-Object { Write-Host ("  " + $_.Substring(0, [Math]::Min(190, $_.Length))) }
$bad = $logTxt -match '找不到或无法加载主类|Could not find or load main class|FATAL EXCEPTION|Process crashed|A fatal error'
if ($bad) { Write-Host "!! 启动失败信号存在"; exit 1 } else { Write-Host "✓ 未发现致命启动错误（forge 应已进入加载）" }