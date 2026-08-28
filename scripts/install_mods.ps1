# =============================================================
# Starfall Chronicles — 模组安装器（PowerShell）
# 从 Modrinth API 下载全部模组到 pack/.minecraft/mods （1.20.1 + Forge 最新版）
# 用法:
#   pwsh ./scripts/install_mods.ps1                 # 安装 required
#   pwsh ./scripts/install_mods.ps1 -IncludeOptional # 额外安装 optional 模组(Oculus)
#   pwsh ./scripts/install_mods.ps1 -DryRun         # 只列出将下载的内容
# 注意:
#   - CurseForge 独有模组(Flux Networks / MineColonies)需手动下载，脚本会打印链接。
#   - 已存在的同名 jar 会跳过（可 -Force 覆盖）。
# =============================================================
[CmdletBinding()]
param(
    [switch]$IncludeOptional,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ConfigPath = Join-Path $PSScriptRoot 'mods.json'
$ApiBase = 'https://api.modrinth.com/v2'
$ua = 'starfall-chronicles-installer/1.0 (dsh; github public repo)'

if (-not (Test-Path $ConfigPath)) { throw "找不到 mods.json: $ConfigPath" }
$cfg = Get-Content $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json

$installDir = Join-Path $RepoRoot $cfg.pack.install_dir
if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $installDir | Out-Null }

$entries = @()
foreach ($m in $cfg.mods) {
    if ($m.tier -eq 'required') { $entries += $m }
    elseif ($m.tier -eq 'optional' -and $IncludeOptional) { $entries += $m }
}
# optional_mods 仅在 -IncludeOptional 时加入（图形类默认跳过，规避渲染兼容性问题）
if ($IncludeOptional) { foreach ($m in $cfg.optional_mods) { $entries += $m } }

Write-Host "== Starfall Chronicles: 共 $($entries.Count) 个模组待解析 (MC $($cfg.pack.mc_version) / $($cfg.pack.loader)) =="

$downloads = @()
foreach ($m in $entries) {
    $url = "$ApiBase/project/$($m.slug)/version?game_versions=%5B%22$($cfg.pack.mc_version)%22%5D&loaders=%5B%22$($cfg.pack.loader)%22%5D"
    try {
        $vers = Invoke-RestMethod -Uri $url -Headers @{ 'User-Agent' = $ua } -TimeoutSec 30
    } catch {
        Write-Warning "  [$($m.slug)] API 查询失败: $($_.Exception.Message)"
        continue
    }
    $v = $vers | Select-Object -First 1
    if (-not $v) {
        Write-Warning "  [$($m.slug)] 没有 $($cfg.pack.mc_version)+$($cfg.pack.loader) 版本 —— 请去 CurseForge 手动安装"
        continue
    }
    $file = $v.files | Select-Object -First 1
    $dest = Join-Path $installDir $file.filename
    $downloads += [pscustomobject]@{
        slug = $m.slug; version = $v.version_number; filename = $file.filename
        url = $file.url; dest = $dest
    }
    Write-Host ("  [{0,-22}] {1,-24} -> {2}" -f $m.slug, $v.version_number, $file.filename)
}

if ($DryRun) {
    Write-Host "`n[DryRun] 共 $($downloads.Count) 个文件将被下载。未执行任何写入。"
} else {
    $total = 0
    foreach ($d in $downloads) {
        if (Test-Path $d.dest) {
            if (-not $Force) { Write-Host "  跳过(已存在): $($d.filename)"; continue }
            Remove-Item $d.dest -Force
        }
        Write-Host "  下载: $($d.filename) ..."
        Invoke-WebRequest -Uri $d.url -OutFile $d.dest -Headers @{ 'User-Agent' = $ua } -TimeoutSec 120
        $size = (Get-Item $d.dest).Length
        $total += $size
        Write-Host ("     OK ({0:N1} MB)" -f ($size / 1MB))
    }
    Write-Host ("`n完成：下载 {0} 个文件，共 {1:N1} MB → {2}" -f $downloads.Count, ($total / 1MB), $installDir)

    if ($cfg.curseforge_only) {
        Write-Host "`n--- CurseForge 独有模组（Modrinth 无 Forge 1.20.1 版本，请手动下载 jar 放入 mods/）---"
        foreach ($c in $cfg.curseforge_only) {
            Write-Host ("  * {0}: {1}" -f $c.name, $c.page)
            if ($c.why) { Write-Host ("    用途: {0}" -f $c.why) }
        }
    }
}