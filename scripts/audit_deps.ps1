# =============================================================
# Starfall Chronicles — 模组依赖审计
# 对 scripts/mods.json 中每个模组，从 Modrinth API 拉取
# “1.20.1 + forge 最新版”的依赖列表，标记 required/optional 依赖，
# 并报告未收录的 required 依赖（缺失前置 = 崩溃头号原因）。
# 用法: pwsh ./scripts/audit_deps.ps1
# =============================================================
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$h = @{ 'User-Agent' = 'starfall-chronicles-audit/1.0 (dsh)' }
$cfgPath = Join-Path $PSScriptRoot 'mods.json'
$cfg = Get-Content $cfgPath -Raw -Encoding UTF8 | ConvertFrom-Json

$have = @{}
foreach ($m in $cfg.mods) { $have[$m.slug] = $true }
foreach ($m in $cfg.optional_mods) { $have[$m.slug] = $true }

# slug 与 project id 的映射缓存
$idToSlug = @{}
$slugToId = @{}
function Resolve-Project($id) {
    if ($idToSlug.ContainsKey($id)) { return $idToSlug[$id] }
    try {
        $r = Invoke-RestMethod -Uri "https://api.modrinth.com/v2/project/$id" -Headers $h -TimeoutSec 20
        $slug = $r.slug
        $idToSlug[$id] = $slug; $slugToId[$slug] = $id
        return $slug
    } catch { return "unknown:$id" }
}

$missing = @(); $foundDeps = @()
foreach ($m in $cfg.mods) {
    if ($global:skip -and $m.slug -notin $cfg.mods.slug) { }
    try {
        $url = "https://api.modrinth.com/v2/project/$($m.slug)/version?game_versions=%5B%22$($cfg.pack.mc_version)%22%5D&loaders=%5B%22$($cfg.pack.loader)%22%5D"
        $vers = Invoke-RestMethod -Uri $url -Headers $h -TimeoutSec 20
        $v = $vers | Select-Object -First 1
        if (-not $v) { continue }
        foreach ($d in $v.dependencies) {
            if ($d.dependency_type -eq 'required') {
                $dslug = Resolve-Project $d.project_id
                $foundDeps += [pscustomobject]@{ owner = $m.slug; dep = $dslug; type = 'required' }
                if (-not $have.ContainsKey($dslug)) {
                    $missing += [pscustomobject]@{ owner = $m.slug; dep = $dslug; kind = 'REQUIRED' }
                }
            } elseif ($d.dependency_type -eq 'optional' -or $d.dependency_type -eq 'incompatible') {
                $dslug = Resolve-Project $d.project_id
                if ($d.dependency_type -eq 'incompatible' -and $have.ContainsKey($dslug)) {
                    $missing += [pscustomobject]@{ owner = $m.slug; dep = $dslug; kind = 'INCOMPATIBLE-PRESENT!' }
                }
            }
        }
    } catch { Write-Warning "  audit FAIL: $($m.slug) :: $($_.Exception.Message)" }
    Start-Sleep -Milliseconds 120
}

Write-Host "=== required 依赖（已收录的也列出以便核对）==="
$foundDeps | Sort-Object dep | Format-Table -AutoSize | Out-String -Width 160

Write-Host "=== 审计结论 ==="
if ($missing.Count -eq 0) {
    Write-Host "✔ 无缺失 required 依赖、无已收录的 incompatible 冲突。" -ForegroundColor Green
} else {
    $missing | Format-Table -AutoSize | Out-String -Width 160
    Write-Host "✘ 需要补齐的依赖如上。建议加入 mods.json 的 libraries 分类。" -ForegroundColor Red
}