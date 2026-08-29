# =============================================================
# Starfall Chronicles — Modrinth 整合包(.mrpack)生成器
# 产出: dist/starfall-chronicles-<date>.mrpack
# 一键拖入：PCL2 / Prism 直接把 .mrpack 拖进窗口即可安装（自动识别为
#           Modrinth 格式，无需任何手动操作）。
# 实现：全内置 overrides（mods/资源/配置全部打包），index.files 为空数组，
#       dependencies 声明 MC 1.20.1 + Forge 47.4.23。
# 用法: pwsh ./scripts/make_mrpack.ps1
# =============================================================
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$McDir = Join-Path $Root 'pack\.minecraft'
$DistDir = Join-Path $Root 'dist'
New-Item -ItemType Directory -Force -Path $DistDir | Out-Null

$stamp = Get-Date -Format 'yyyyMMdd'
$mrpack = Join-Path $DistDir ("starfall-chronicles-" + $stamp + '.mrpack')

# ---- 1) 工作目录：overrides = .minecraft 内容 ----
$work = Join-Path $DistDir ("mrpack_work_" + $stamp)
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Force -Path $work | Out-Null
$ovr = Join-Path $work 'overrides'
New-Item -ItemType Directory -Force -Path $ovr | Out-Null
Get-ChildItem -Path $McDir -Force | Where-Object { $_.Name -ne 'mods_cache' } | ForEach-Object {
  Copy-Item $_.FullName (Join-Path $ovr $_.Name) -Recurse -Force
}
Write-Host ("overrides 同步完成: " + (Get-ChildItem $ovr -Directory | Select-Object -ExpandProperty Name) -join ', ')

# ---- 2) modrinth.index.json（files 空 = 全内置 overrides；依赖声明版本）----
$index = [ordered]@{
  formatVersion = 1
  game = 'minecraft'
  versionId = 'starciv-1.0.0'
  name = 'Starfall Chronicles | 星际文明编年史'
  summary = '四星球 × 四文明阶段。农业→工业→信息→星际，星门跃迁 + 任务书 + 成就 + 光影与音乐。'
  files = [array]@()
  dependencies = [ordered]@{ minecraft = '1.20.1'; forge = '47.4.23' }
}
$indexJson = $index | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText((Join-Path $work 'modrinth.index.json'), $indexJson, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "modrinth.index.json 已写"

# ---- 3) 正斜杠打包（与 build_pcl_pack 同款，避免 PS5.1 反斜杠坑）----
Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null
Add-Type -AssemblyName System.IO.Compression | Out-Null
if (Test-Path $mrpack) { Remove-Item $mrpack -Force }
$fs = [System.IO.File]::Open($mrpack, [System.IO.FileMode]::Create)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
try {
  $base = $work.TrimEnd('\') + '\'
  $dirs = New-Object System.Collections.Generic.HashSet[string]
  Get-ChildItem -Path $work -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($base.Length).Replace('\', '/')
    $dirRel = Split-Path $rel -Parent
    while ($dirRel) {
      $dirRelPosix = $dirRel.Replace('\', '/')
      if ($dirs.Add($dirRelPosix)) { $null = $zip.CreateEntry($dirRelPosix + '/') }
      $dirRel = Split-Path $dirRel -Parent
    }
    $entry = $zip.CreateEntry($rel, [System.IO.Compression.CompressionLevel]::Optimal)
    $es = $entry.Open()
    try { $bytes = [System.IO.File]::ReadAllBytes($_.FullName); $es.Write($bytes, 0, $bytes.Length) } finally { $es.Dispose() }
  }
} finally { $zip.Dispose(); $fs.Dispose() }

Remove-Item $work -Recurse -Force
$sz = (Get-Item $mrpack).Length / 1MB
Write-Host ("✔ 已生成: " + $mrpack)
Write-Host ("  大小约 {0:N0} MB —— 拖入 PCL2/Prism 窗口即可自动安装" -f $sz)