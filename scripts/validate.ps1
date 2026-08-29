# =============================================================
# Starfall Chronicles — 工程校验器
#   1. 全仓 JSON 可解析性检查
#   2. KubeJS 脚本 node --check 语法检查
#   3. Advancement 父子引用一致性
#   4. mcfunction 空行/注释规则
# 用法: pwsh ./scripts/validate.ps1
# =============================================================
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$fail = 0; $jsonCount = 0

# ---- 1. JSON ----
Write-Host "[1/4] 检查 JSON 可解析性 ..."
Get-ChildItem -Path $Root -Recurse -Filter *.json -File |
    Where-Object { $_.FullName -notmatch '\\(server|node_modules|\.git|downloads|dist|build_pcl)\\' } |
    ForEach-Object {
        $f = $_
        $jsonCount++
        try { $raw = Get-Content $f.FullName -Raw -Encoding UTF8; if ($raw) { $raw | ConvertFrom-Json | Out-Null } }
        catch {
            Write-Host "  [JSON-FAIL] $($f.FullName.Substring($Root.Length)) :: $($_.Exception.Message)" -ForegroundColor Red
            $fail++
        }
    }
Write-Host "  JSON 文件 $jsonCount 个，失败 $fail"

# ---- 2. KubeJS JS 语法 ----
Write-Host "[2/4] node --check KubeJS 脚本 ..."
$node = $null
try { $node = (Get-Command node -ErrorAction Stop).Source } catch { }
if ($node) {
    Get-ChildItem -Path (Join-Path $Root 'pack\.minecraft\kubejs') -Recurse -Filter *.js -File | ForEach-Object {
        & $node --check $_.FullName 2>&1 | ForEach-Object {
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  [JS-FAIL] $($f.FullName.Substring($Root.Length)) :: $_" -ForegroundColor Red
                $fail++
            }
        }
    }
    Write-Host "  node --check 完成"
} else {
    Write-Host "  警告: 未找到 node，跳过 JS 语法检查" -ForegroundColor Yellow
}

# ---- 3. Advancement 引用 ----
Write-Host "[3/4] 校验 Advancement parent 引用 ..."
$advDir = Join-Path $Root 'pack\.minecraft\kubejs\data\starciv\advancements'
if (Test-Path $advDir) {
    $advs = Get-ChildItem $advDir -Recurse -Filter *.json -File
    $ids = @{}
    foreach ($a in $advs) {
        $rel = $a.FullName.Substring($advDir.Length + 1) -replace '\\','/'
        $id = 'starciv:' + ($rel -replace '\.json$','')
        $ids[$id] = $true
    }
    foreach ($a in $advs) {
        $obj = Get-Content $a.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($obj.PSObject.Properties.Name -contains 'parent' -and $obj.parent) {
            if (-not $ids.ContainsKey($obj.parent)) {
                Write-Host "  [ADV-FAIL] $($a.Name) 引用不存在的 parent: $($obj.parent)" -ForegroundColor Red
                $fail++
            }
        }
    }
    Write-Host "  Advancement $($advs.Count) 个引用检查完成"
} else { Write-Host "  跳过: 无 advancements 目录" -ForegroundColor Yellow }

# ---- 4. mcfunction ----
Write-Host "[4/4] 检查 mcfunction 行尾 ..."
$fnDir = Join-Path $Root 'pack\.minecraft\kubejs\data\starciv\functions'
if (Test-Path $fnDir) {
    $bad = 0
    Get-ChildItem $fnDir -Recurse -Filter *.mcfunction -File | ForEach-Object {
        if ((Get-Content $_.FullName -Raw -Encoding UTF8) -match '\r') { $bad++ }
    }
    if ($bad -gt 0) { Write-Host "  [FN-FAIL] $bad 个 mcfunction 含 CRLF（Minecraft 要求 LF）" -ForegroundColor Red; $fail += $bad }
    else { Write-Host "  mcfunction 行尾检查通过" }
} else { Write-Host "  跳过: 无 functions 目录" -ForegroundColor Yellow }

# ---- 5. PS1 编码（恰一个 UTF-8 BOM；双重 BOM 会导致 PowerShell 解析失败）----
Write-Host "[5/5] 检查脚本编码（.ps1 单 BOM 规范）..."
$scriptFiles = @()
$scriptFiles += (Get-ChildItem (Join-Path $Root 'scripts') -Filter *.ps1 -File)
$scriptFiles += (Get-ChildItem (Join-Path $Root 'server') -Filter *.ps1 -File)
foreach ($sf in $scriptFiles) {
    $bytes = [System.IO.File]::ReadAllBytes($sf.FullName)
    $bomCount = 0
    $i = 0
    while ($i + 2 -lt $bytes.Length -and $bytes[$i] -eq 0xEF -and $bytes[$i+1] -eq 0xBB -and $bytes[$i+2] -eq 0xBF) { $bomCount++; $i += 3 }
    if ($bomCount -ne 1) {
        Write-Host "  [ENC-FAIL] $($sf.Name) BOM 数量=$bomCount（应为 1；0=旧 PS 按 ANSI 误读中文，2=解析失败）" -ForegroundColor Red
        $fail++
    }
}
if ($fail -eq 0) { Write-Host "  编码检查通过" } else { Write-Host "  编码检查存在失败项" -ForegroundColor Yellow }

Write-Host ""
if ($fail -eq 0) { Write-Host "✔ 全部校验通过" -ForegroundColor Green }
else { Write-Host "✘ 共 $fail 处失败" -ForegroundColor Red; exit 1 }