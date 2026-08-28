# =============================================================
# Starfall Chronicles — PCL2 拖入即用的离线整合包构建器
# 产出: dist/starfall-chronicles-pcl.zip
#   内容: .minecraft/versions/1.20.1-forge-47.4.23 （完整 Forge 客户端
#         + libraries）+ mods + datapacks + resourcepacks
#   PCL2: 首页 -> 安装整合包 -> 导入本地整合包 -> 选择该 zip
# 参数:
#   -SkipForge      跳过 Forge 客户端安装（只刷新 mods/数据包/资源包）
#   -GameDir <路径> 直接部署到 PCL2 游戏目录的 .minecraft（不打包）
#   -AcceptEula     不需要
# 注意: 需要本机已装 Java 17（正版/官方安装器要求）
# =============================================================
[CmdletBinding()]
param(
  [switch]$SkipForge,
  [string]$GameDir = ''
)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ForgeVer = '1.20.1-47.4.23'
$InstallerUrl = "https://maven.minecraftforge.net/net/minecraftforge/forge/$ForgeVer/forge-$ForgeVer-installer.jar"

if ($GameDir) { $mcDir = Join-Path $GameDir '.minecraft' } else { $mcDir = Join-Path (Join-Path $Root 'build_pcl') '.minecraft' }
New-Item -ItemType Directory -Force -Path $mcDir | Out-Null

# ---- 0. Java 17 ----
function Get-JavaCmd {
  $cands = @(); if ($env:JAVA_HOME) { $cands += (Join-Path $env:JAVA_HOME 'bin\java.exe') }; $cands += 'java'
  foreach ($c in $cands) {
    try {
      $old = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
      $v = (& $c '-version' 2>&1 | Select-Object -First 1)
      $ErrorActionPreference = $old
      if ("$v" -match 'version "(\d+)' -and [int]$Matches[1] -eq 17) { return $c }
    } catch {}
  }
  Write-Host "需要 Java 17 (64位): https://adoptium.net/temurin/releases/?version=17" -ForegroundColor Red; exit 1
}
$JavaCmd = Get-JavaCmd

# ---- 1. 模组 ----
$srcMods = Join-Path $Root 'pack\.minecraft\mods'
$modCount = 0
if (Test-Path $srcMods) { $modCount = (Get-ChildItem $srcMods -Filter *.jar).Count }
if ($modCount -lt 60) {
  Write-Host "模组不足（$modCount 个），先下载..."
  & (Join-Path $PSScriptRoot 'install_mods.ps1') -IncludeOptional
  $modCount = (Get-ChildItem $srcMods -Filter *.jar).Count
}
Write-Host "模组: $modCount 个 jar"

# ---- 2. Forge 客户端安装（一次即可，之后 -SkipForge）----
# Forge 客户端版本 ID 形如 1.20.1-forge-47.4.23（与服务端包不同）
$ForgeVerId = '1.20.1-forge-' + ($ForgeVer -replace '^1\.20\.1-', '')
$verDir = Join-Path $mcDir "versions\$ForgeVerId"
$vanillaDir = Join-Path $mcDir 'versions\1.20.1'
if (-not (Test-Path $verDir) -and -not $SkipForge) {
  # 2a. 引导原版 1.20.1 档案。每次无条件重刷（幂等、无 BOM）：
  #     Forge --installClient 要求 ①原版版本 json ②launcher_profiles.json ③client.jar
  Write-Host "== 引导原版 1.20.1 版本档案 =="
  New-Item -ItemType Directory -Force -Path $vanillaDir | Out-Null
  $manifest = Invoke-RestMethod -Uri 'https://piston-meta.mojang.com/mc/game/version_manifest_v2.json' -TimeoutSec 60
  $v1201 = $manifest.versions | Where-Object { $_.id -eq '1.20.1' } | Select-Object -First 1
  if (-not $v1201) { Write-Host "版本清单中找不到 1.20.1"; exit 1 }
  $pkg = Invoke-RestMethod -Uri $v1201.url -TimeoutSec 60
  # JSON 必须无 BOM（Forge/Gson 解析带 BOM 的 JSON 会直接失败）
  $vanillaJson = $pkg | ConvertTo-Json -Depth 12
  [System.IO.File]::WriteAllText((Join-Path $vanillaDir '1.20.1.json'), $vanillaJson, (New-Object System.Text.UTF8Encoding($false)))
  if (-not (Test-Path (Join-Path $vanillaDir '1.20.1.jar'))) {
    Write-Host "== 下载原版 client.jar（离线启动必需，约 25MB）=="
    Invoke-WebRequest -Uri $pkg.downloads.client.url -OutFile (Join-Path $vanillaDir '1.20.1.jar') -TimeoutSec 300
  }
  # launcher_profiles.json —— Forge 安装器读它判断“启动档案”
  $profiles = @{
    clientToken = 'starfall-chronicles'
    authenticationDatabase = @{}
    selectedUser = @{ account = ''; profile = '' }
    launcherVersion = @{ name = 'starfall'; format = 21 }
    profiles = @{
      '1.20.1' = @{
        created = '2026-08-28T00:00:00.000Z'; icon = 'Crafting_Table'
        lastUsed = '2026-08-28T00:00:00.000Z'; lastVersionId = '1.20.1'
        name = '1.20.1'; type = 'latest-release'
      }
    }
    selectedProfile = '1.20.1'
  }
  $profilesJson = $profiles | ConvertTo-Json -Depth 6
  [System.IO.File]::WriteAllText((Join-Path $mcDir 'launcher_profiles.json'), $profilesJson, (New-Object System.Text.UTF8Encoding($false)))
  Write-Host "== 安装 Forge 客户端（首次下载 libraries 约 200-300MB，仅一次）=="
  $installer = Join-Path $Root 'downloads\forge-installer.jar'
  New-Item -ItemType Directory -Force -Path (Split-Path $installer) | Out-Null
  Invoke-WebRequest -Uri $InstallerUrl -OutFile $installer -TimeoutSec 300
  & $JavaCmd -jar $installer --installClient $mcDir
  if ($LASTEXITCODE -ne 0) { Write-Host "Forge 客户端安装失败"; exit 1 }
  Remove-Item $installer -Force -ErrorAction SilentlyContinue
  # 安装器可能把 Forge 版本 json 写进 versions/1.20.1/，需挪到独立版本目录（PCL 要求）
  New-Item -ItemType Directory -Force -Path $verDir | Out-Null
  $stray = Get-ChildItem $vanillaDir -Filter "*forge*.json" -File -ErrorAction SilentlyContinue
  foreach ($s in $stray) {
    Move-Item $s.FullName (Join-Path $verDir ($ForgeVerId + '.json')) -Force -ErrorAction SilentlyContinue
    Write-Host "  (已迁移版本 json: $($s.Name) → versions/$ForgeVerId/)"
  }
  if (-not (Test-Path (Join-Path $verDir ($ForgeVerId + '.json')))) {
    Write-Host "无法找到安装好的 Forge 版本 json" -ForegroundColor Red; exit 1
  }
} elseif (-not (Test-Path $verDir)) {
  Write-Host "跳过 Forge 安装但版本目录不存在：$verDir" -ForegroundColor Yellow
}

# ---- 3. 内容同步 ----
Write-Host "== 同步 mods / datapacks / resourcepacks / shaderpacks / kubejs =="
foreach ($sub in @('mods','datapacks','kubejs')) {
  $src = Join-Path $Root "pack\.minecraft\$sub"
  if (Test-Path $src) {
    if (Test-Path (Join-Path $mcDir $sub)) { Remove-Item (Join-Path $mcDir $sub) -Recurse -Force }
    Copy-Item $src (Join-Path $mcDir $sub) -Recurse -Force
  }
}
# 全部资源包（starciv_resources 专属 + Better Vanilla Building 建筑材质）
$rpSrcRoot = Join-Path $Root 'pack\.minecraft\resourcepacks'
if (Test-Path $rpSrcRoot) {
  foreach ($rp in (Get-ChildItem $rpSrcRoot -Directory)) {
    $rpDst = Join-Path $mcDir ("resourcepacks\" + $rp.Name)
    if (Test-Path $rpDst) { Remove-Item $rpDst -Recurse -Force }
    Copy-Item $rp.FullName $rpDst -Recurse -Force
  }
}
# 光影（客户端专属，服务端同步脚本本就不带 shaderpacks）
$shSrc = Join-Path $Root 'pack\.minecraft\shaderpacks'
if (Test-Path $shSrc) {
  $shDst = Join-Path $mcDir 'shaderpacks'
  if (Test-Path $shDst) { Remove-Item $shDst -Recurse -Force }
  Copy-Item $shSrc $shDst -Recurse -Force
}
# 默认启用本包资源包（含 Better Vanilla Building，可在游戏内调整顺序/关闭）
$optPath = Join-Path $mcDir 'options.txt'
$opt = @(
  'resourcePacks:["vanilla","file/starciv_resources","file/better_vanilla_building"]',
  'incompatibleResourcePacks:[]'
) -join "`n"
[System.IO.File]::WriteAllText($optPath, $opt, (New-Object System.Text.UTF8Encoding($false)))
# 打包根目录的空 datapacks 提示
if (-not (Test-Path (Join-Path $mcDir 'datapacks'))) { New-Item -ItemType Directory -Force -Path (Join-Path $mcDir 'datapacks') | Out-Null }

# ---- 4. 版本 JSON 里必须有 libraries 指向（installClient 已处理）----
$verJson = Join-Path $verDir "$ForgeVerId.json"
if (-not (Test-Path $verJson)) { Write-Host "缺少版本 JSON: $verJson"; exit 1 }

if ($GameDir) {
  Write-Host "已直接部署到 PCL2 游戏目录: $mcDir"
  Write-Host "启动前请确认 PCL2 已识别版本 '1.20.1-forge-47.4.23'，并在『设置-游戏目录』指向该目录。" -ForegroundColor Green
  exit 0
}

# ---- 5. 打包 ----
$dist = Join-Path $Root 'dist'
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$zipPath = Join-Path $dist ("starfall-chronicles-pcl-" + (Get-Date -Format yyyyMMdd) + '.zip')
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null
# PCL 约定: zip 根内直接是 .minecraft/*（包含 .minecraft 这一层再压缩）
$zipRoot = Split-Path $mcDir -Parent
[System.IO.Compression.ZipFile]::CreateFromDirectory($zipRoot, $zipPath, [System.IO.Compression.CompressionLevel]::Optimal, $false)
Write-Host "✔ 已生成 PCL2 整合包:" -ForegroundColor Green
Write-Host "  $zipPath"
$sz = (Get-Item $zipPath).Length / 1MB
Write-Host ("  大小约 {0:N0} MB" -f $sz)
Write-Host ""
Write-Host "使用: PCL2 首页 -> 安装整合包 -> 导入本地整合包 -> 选择该 zip"
Write-Host "      首次启动请选版本: 1.20.1-forge-47.4.23"