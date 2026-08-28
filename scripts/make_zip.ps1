# =============================================================
# Starfall Chronicles — 打包脚本
# 将 pack/ 打成一个 ZIP，供 Prism Launcher / MultiMC 直接导入。
# 用法: pwsh ./scripts/make_zip.ps1
# 输出: dist/starfall-chronicles-<date>.zip
# =============================================================
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$PackDir = Join-Path $Root 'pack'
$DistDir = Join-Path $Root 'dist'
New-Item -ItemType Directory -Force -Path $DistDir | Out-Null
$zipName = "starfall-chronicles-$(Get-Date -Format 'yyyyMMdd').zip"
$zip = Join-Path $DistDir $zipName
if (Test-Path $zip) { Remove-Item $zip -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null
Add-Type -AssemblyName System.IO.Compression | Out-Null
# Compress-Archive 在 PS5.1 会把 zip 条目写成反斜杠（zip 规范要求正斜杠），
# 导致 Prism/PCL2 无法识别内容结构 —— 改用 ZipArchive 手工写正斜杠条目（含目录条目）。
function New-PosixZip([string]$srcDir, [string]$dstZip) {
  $fs = [System.IO.File]::Open($dstZip, [System.IO.FileMode]::Create)
  $zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
  try {
    $base = (Resolve-Path $srcDir).Path.TrimEnd('\') + '\'
    $dirs = New-Object System.Collections.Generic.HashSet[string]
    Get-ChildItem -Path $srcDir -Recurse -File | ForEach-Object {
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
}
New-PosixZip $PackDir $zip
Write-Host "已打包: $zip ($('{0:N1}' -f ((Get-Item $zip).Length/1MB)) MB)"
Write-Host "导入方法: Prism Launcher -> 添加实例 -> 从文件导入 -> 选择此 zip (ZIP 内即 .minecraft 内容)"