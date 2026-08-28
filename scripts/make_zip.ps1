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
Compress-Archive -Path (Join-Path $PackDir '*') -DestinationPath $zip -CompressionLevel Optimal
Write-Host "已打包: $zip ($('{0:N1}' -f ((Get-Item $zip).Length/1MB)) MB)"
Write-Host "导入方法: Prism Launcher -> 添加实例 -> 从文件导入 -> 选择此 zip (ZIP 内即 .minecraft 内容)"