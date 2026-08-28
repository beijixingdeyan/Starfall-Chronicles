# =============================================================
# Starfall Chronicles — 运行时物品/实体 ID 校验
# 解压已下载的 mod jar，核对配方/进度引用的物品、实体、维度 ID
# 是否真实存在于对应模组（依据 jar 内 lang / 资产文件）。
# 用法: pwsh ./scripts/verify_mod_ids.ps1
# =============================================================
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$modsDir = Join-Path $Root 'pack\.minecraft\mods'
if (-not (Test-Path $modsDir)) { Write-Host "mods 目录不存在，先运行 install_mods.ps1"; exit 1 }

Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null

# 维护: modid -> 需要校验的 key 集合（lang 前缀精确匹配; * 表示任意存在即可）
$checks = [ordered]@{
  'create'              = @('item.create.iron_sheet', 'item.create.brass_ingot')
  'mekanism'            = @('item.mekanism.dust_gold')
  'ae2'                 = @('block.ae2.controller', 'item.ae2.calculation_processor', 'item.ae2.logic_processor')
  'ad_astra'            = @('item.ad_astra.engine_frame', 'item.ad_astra.steel_plate')
  'computercraft'       = @('block.computercraft.computer_normal')
  'pipez'               = @('block.pipez.item_pipe')   # 管道是方块
  'immersiveengineering'= @('item.immersiveengineering.ingot_steel')
}

# 本包自定义物品验证：查资源包语言文件（无 mod jar）
$starcivKeys = @(
  'item.starciv.ancient_seed', 'item.starciv.civ_essence', 'item.starciv.stellar_key',
  'item.starciv.biofuel_canister', 'item.starciv.data_slivers', 'item.starciv.precision_parts',
  'item.starciv.quantum_core', 'item.starciv.warp_core', 'item.starciv.warp_engine',
  'block.starciv.stargate_core'
)

$entityChecks = @(
  @{ modid = 'cataclysm'; langKey = 'entity.cataclysm.netherite_monstrosity'; usedAs = '进度: interstellar/contact 击杀目标' }
)

$langCache = @{}

# 找到声明了指定 modId 的 jar（逐 section 解析 mods.toml，只认 [[mods]] 块）
function Get-JarForModid([string]$modid) {
  foreach ($f in (Get-ChildItem $modsDir -Filter *.jar)) {
    try {
      $zip = [System.IO.Compression.ZipFile]::OpenRead($f.FullName)
      $e = $zip.Entries | Where-Object { $_.FullName -eq 'META-INF/mods.toml' } | Select-Object -First 1
      if ($e) {
        $sr = New-Object System.IO.StreamReader($e.Open(), [Text.Encoding]::UTF8)
        $toml = $sr.ReadToEnd(); $sr.Close()
        $section = ''
        foreach ($line in ($toml -split "`r?`n")) {
          if ($line -match '^\s*\[\[([^\]]+)\]\]') { $section = "[[" + $Matches[1] + "]]" }
          elseif ($line -match '^\s*\[([^\]]+)\]') { $section = "[" + $Matches[1] + "]" }
          elseif ($section -eq '[[mods]]' -and $line -match ('modId\s*=\s*"' + [regex]::Escape($modid) + '"')) {
            $zip.Dispose(); return $f
          }
        }
      }
      $zip.Dispose()
    } catch { }
  }
  return $null
}

# 多语言兜底: 依次查找 en_us / en_GB / 任意
function Get-NamespaceLang($jarPath, $ns) {
  $cacheKey = $jarPath
  if ($langCache.ContainsKey($cacheKey)) { return $langCache[$cacheKey] }
  $found = @{}
  try {
    $zip = [System.IO.Compression.ZipFile]::OpenRead($jarPath)
    foreach ($entry in $zip.Entries) {
      if ($entry.FullName -match "^assets/$ns/lang/[^/]+\.json$") {
        $sr = New-Object System.IO.StreamReader($entry.Open(), [Text.Encoding]::UTF8)
        $json = $sr.ReadToEnd(); $sr.Close()
        try { $obj = $json | ConvertFrom-Json } catch { continue }
        foreach ($p in $obj.PSObject.Properties) { $found[$p.Name] = $true }
      }
    }
    $zip.Dispose()
  } catch { }
  $langCache[$cacheKey] = $found
  return $found
}

$fail = 0
Write-Host "=== 物品/方块 ID 校验 ==="
foreach ($modid in $checks.Keys) {
  $jar = Get-JarForModid $modid
  if (-not $jar) { Write-Host "  [MISSING-MOD] $modid 未找到对应 jar！" -ForegroundColor Red; $fail++; continue }

  $lang = Get-NamespaceLang $jar.FullName $modid
  foreach ($key in $checks[$modid]) {
    $langKey = $key
    if ($key.StartsWith('item.')) { $langKey = $key } elseif ($key.StartsWith('block.')) { $langKey = $key }
    if ($lang.ContainsKey($langKey)) {
      Write-Host ("  [OK] {0} ({1})" -f $key, (Split-Path $jar.Name -Leaf)) -ForegroundColor Green
    } else {
      # 兜底: 检查 item/block 均不存在则报错
      Write-Host "  [FAIL] $key 未在 $($jar.Name) 的 lang 中找到" -ForegroundColor Red
      $fail++
    }
  }
}

Write-Host "=== 实体 ID 校验 ==="
foreach ($ec in $entityChecks) {
  $jar = Get-JarForModid $ec.modid
  if (-not $jar) { Write-Host "  [MISSING-MOD] $($ec.modid)" -ForegroundColor Red; $fail++; continue }
  $lang = Get-NamespaceLang $jar.FullName $ec.modid
  if ($lang.ContainsKey($ec.langKey)) {
    Write-Host ("  [OK] {0} （{1}）" -f $ec.langKey, $ec.usedAs) -ForegroundColor Green
  } else {
    Write-Host "  [FAIL] $($ec.langKey) 未找到（$($ec.usedAs)）" -ForegroundColor Red
    $fail++
  }
}

Write-Host "=== 本包自定义物品校验（资源包 lang）==="
$rpLang = Join-Path $Root 'pack\.minecraft\resourcepacks\starciv_resources\assets\starciv\lang\zh_cn.json'
if (Test-Path $rpLang) {
  $rpObj = Get-Content $rpLang -Raw -Encoding UTF8 | ConvertFrom-Json
  foreach ($k in $starcivKeys) {
    if ($rpObj.PSObject.Properties.Name -contains $k) {
      Write-Host "  [OK] $k" -ForegroundColor Green
    } else {
      Write-Host "  [FAIL] 资源包缺少 lang key: $k" -ForegroundColor Red
      $fail++
    }
  }
} else {
  Write-Host "  [FAIL] 资源包语言文件不存在: $rpLang" -ForegroundColor Red
  $fail++
}

Write-Host ""
if ($fail -eq 0) { Write-Host "✔ 全部运行时 ID 校验通过" -ForegroundColor Green } else { Write-Host "✘ $fail 处失败" -ForegroundColor Red; exit 1 }