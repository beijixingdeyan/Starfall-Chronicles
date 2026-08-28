# =============================================================
# Starfall Chronicles — Forge 服务端一键启动（Windows / PowerShell）
# 功能：自动检测 Java17 → 下载并安装 Forge 47.4.23 → 同步模组
#       → 放置数据包 → 启动服务器。
# 用法：
#   首次运行:  ./start-server.ps1         （会询问是否接受 EULA）
#   静默模式:  ./start-server.ps1 -AcceptEula
#   只同步:    ./start-server.ps1 -SyncOnly
# =============================================================
[CmdletBinding()]
param(
  [switch]$AcceptEula,
  [switch]$SyncOnly
)
$ErrorActionPreference = 'Stop'
$ServerDir = (Resolve-Path $PSScriptRoot).Path
$ForgeVer = '1.20.1-47.4.23'
$MCVer    = '1.20.1'
$InstallerUrl = "https://maven.minecraftforge.net/net/minecraftforge/forge/$ForgeVer/forge-$ForgeVer-installer.jar"

# ---------- Java 检测（仅检测，不脱离路径信息）----------
function Get-JavaCmd {
  $cands = @()
  if ($env:JAVA_HOME) { $cands += (Join-Path $env:JAVA_HOME 'bin\java.exe') }
  $cands += 'java'
  foreach ($c in $cands) {
    try {
      $old = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
      $v = (& $c '-version' 2>&1 | Select-Object -First 1)
      $ErrorActionPreference = $old
      if ("$v" -match 'version "(\d+)' -and [int]$Matches[1] -eq 17) { Write-Host "Java 17 OK: $c"; return $c }
    } catch {}
  }
  Write-Host "未找到 Java 17（64 位）。请安装后重试：https://adoptium.net/temurin/releases/?version=17" -ForegroundColor Red
  exit 1
}
$JavaCmd = Get-JavaCmd

# ---------- Forge 服务端安装 ----------
if (-not (Test-Path (Join-Path $ServerDir 'libraries'))) {
  Write-Host "== 下载 Forge $ForgeVer 服务端安装器（约 5MB）=="
  $installer = Join-Path $ServerDir "forge-$ForgeVer-installer.jar"
  Invoke-WebRequest -Uri $InstallerUrl -OutFile $installer -TimeoutSec 300
  if ((Get-Item $installer).Length -lt 1MB) { Write-Host "安装器下载异常（文件过小）"; exit 1 }
  Write-Host "== 安装 Forge 服务端 =="
  & $JavaCmd -jar $installer --installServer $ServerDir
  if ($LASTEXITCODE -ne 0) { Write-Host "Forge 服务端安装失败"; exit 1 }
  Remove-Item $installer -Force -ErrorAction SilentlyContinue
}

# ---------- EULA ----------
# eula.txt 必须恰好是 "eula=true"（服务端逐字符比对；BOM/多余字符都会导致拒绝）
$eulaFile = Join-Path $ServerDir 'eula.txt'
$eulaOk = $false
if (Test-Path $eulaFile) {
  $eulaText = [System.IO.File]::ReadAllText($eulaFile)
  $eulaOk = $eulaText.Trim() -eq 'eula=true'
  if (-not $eulaOk) { Write-Host "检测到 eula.txt 内容异常（可能带 BOM），将自动重写。" -ForegroundColor Yellow }
}
if (-not $eulaOk) {
  if (-not $AcceptEula) {
    $ans = Read-Host "是否接受 Minecraft EULA（https://aka.ms/MinecraftEULA）？输入 y 继续"
    if ($ans.ToLower() -ne 'y') { Write-Host "已取消"; exit 0 }
  }
  [System.IO.File]::WriteAllText($eulaFile, "eula=true`r`n", (New-Object System.Text.ASCIIEncoding))
  Write-Host "已写入 eula.txt（运行脚本即视为接受 EULA）"
}

# ---------- 同步模组 ----------
# 纯客户端模组（光影/渲染）不能进服务端，否则 Forge 直接致命失败
$ClientOnlyPrefix = @('oculus-')
$srcMods = Join-Path $ServerDir '..\pack\.minecraft\mods'
$dstMods = Join-Path $ServerDir 'mods'
if (Test-Path $srcMods) {
  New-Item -ItemType Directory -Force -Path $dstMods | Out-Null
  Get-ChildItem $dstMods -Filter *.jar -ErrorAction SilentlyContinue | Remove-Item -Force
  $copied = 0; $skipped = @()
  Get-ChildItem $srcMods -Filter *.jar | ForEach-Object {
    $skip = $false
    foreach ($p in $ClientOnlyPrefix) { if ($_.Name -like ($p + '*')) { $skip = $true; break } }
    if ($skip) { $skipped += $_.Name } else { Copy-Item $_.FullName $dstMods -Force; $copied++ }
  }
  if ($skipped.Count -gt 0) { Write-Host ("模组同步完成：{0} 个 jar（跳过纯客户端: {1}）" -f $copied, ($skipped -join ', ')) }
  else { Write-Host "模组同步完成：$copied 个 jar" }
} else {
  Write-Host "警告：$srcMods 不存在，请先运行 scripts/install_mods.ps1" -ForegroundColor Yellow
}

# ---------- 数据包（世界已存在时自动放入）----------
$dpSrc = Join-Path $ServerDir '..\pack\.minecraft\datapacks\starciv_dp'
$worldDir = Join-Path $ServerDir 'world'
if ((Test-Path $dpSrc) -and (Test-Path $worldDir)) {
  $dstDp = Join-Path $worldDir 'datapacks\starciv_dp'
  if (Test-Path $dstDp) { Remove-Item $dstDp -Recurse -Force }
  Copy-Item $dpSrc $dstDp -Recurse -Force
  Write-Host "数据包已放入世界: world/datapacks/starciv_dp"
}

# ---------- KubeJS 脚本（必须同步：自定义物品/配方/阶段全部由脚本定义）----------
$kjsSrc = Join-Path $ServerDir '..\pack\.minecraft\kubejs'
$kjsDst = Join-Path $ServerDir 'kubejs'
if (Test-Path $kjsSrc) {
  if (Test-Path $kjsDst) { Remove-Item $kjsDst -Recurse -Force }
  Copy-Item $kjsSrc $kjsDst -Recurse -Force
  Write-Host "KubeJS 脚本已同步: kubejs/scripts"
} else {
  Write-Host "警告：$kjsSrc 不存在（KubeJS 自定义内容将缺失）" -ForegroundColor Yellow
}
if (Test-Path $dpSrc) {
  Write-Host "首次启动：世界尚未生成。服务器首次启动结束（Ctrl+C/stop）后再次运行本脚本，自动放置数据包。" -ForegroundColor Yellow
}

if ($SyncOnly) { Write-Host "同步完成(SyncOnly)。"; exit 0 }

# ---------- JVM 参数 ----------
# 注意：@args 文件必须无 BOM，否则 JVM 会把 BOM 拼进首个参数导致秒退
$jvmArgsFile = Join-Path $ServerDir 'user_jvm_args.txt'
if (Test-Path (Join-Path $ServerDir 'user_jvm_args.txt.tpl')) {
  Copy-Item (Join-Path $ServerDir 'user_jvm_args.txt.tpl') $jvmArgsFile -Force
} elseif (-not (Test-Path $jvmArgsFile)) {
  $jvmLine = '-Xmx6G -Xms2G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1MixedGCCountTarget=4 -XX:SurvivorRatio=32 -XX:+AlwaysPreTouch'
  [System.IO.File]::WriteAllText($jvmArgsFile, $jvmLine, (New-Object System.Text.UTF8Encoding($false)))
}

# ---------- 启动 ----------
# Windows 必须用 win_args.txt（unix_args.txt 的 classpath 是 ':' 分隔，Windows 上无法解析）
$argsFile = Join-Path $ServerDir "libraries\net\minecraftforge\forge\$ForgeVer\win_args.txt"
if (-not (Test-Path $argsFile)) { Write-Host "找不到 Forge 运行参数文件: $argsFile"; exit 1 }
Write-Host "== 启动 Starfall Chronicles 服务端（MC $MCVer / Forge $ForgeVer）=="
& $JavaCmd "@$jvmArgsFile" "@$argsFile" nogui
Write-Host "服务端已停止。"