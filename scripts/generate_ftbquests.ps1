# 生成 FTB Quests 任务书（乌托邦同款树状任务书）
# 输入：config/questlog/quests/*.json（112 任务）
# 输出：config/ftbquests/quests/chapters/*.snbt + data.snbt（树状布局、主线串行、支线链式）
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path '.').Path
$qlDir = Join-Path $root 'pack\.minecraft\config\questlog\quests'
$fqRoot = Join-Path $root 'pack\.minecraft\config\ftbquests\quests'
$chDir = Join-Path $fqRoot 'chapters'
New-Item -ItemType Directory -Force -Path $chDir | Out-Null
Get-ChildItem $chDir -Filter *.snbt | Remove-Item -Force
$enc = New-Object System.Text.UTF8Encoding($false)

function UID([string]$s) {
  $md5 = [System.Security.Cryptography.MD5]::Create()
  $h = $md5.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($s))
  return (($h | ForEach-Object { $_.ToString('X2') }) -join '').Substring(0, 16)
}
function S([string]$s) {
  if ($null -eq $s) { return '""' }
  return '"' + ($s -replace '\\', '\\\\' -replace '"', '\"' -replace "`r", '' -replace "`n", '\n') + '"'
}
function ItemBlock([string]$id, [int]$count) {
  return "{ Count: $count, id: `"$id`", tag: { } }"
}

# ---- 章节定义（id → 标题/图标/任务id正则）----
$chapters = [ordered]@{
  main        = @{ title = '⭐ 主线'; icon = 'minecraft:nether_star';    pats = @('^q0','^q1') }
  tech        = @{ title = '🔧 科技'; icon = 'minecraft:blast_furnace';  pats = @('^s1_workshop','^s2_smeltery','^s6_axles','^s7_pipes','^x_tech') }
  creatures   = @{ title = '🐝 动物'; icon = 'minecraft:honeycomb';      pats = @('^c1_farm','^c2_pet','^c3_bees','^x_mob') }
  building    = @{ title = '🧱 建筑'; icon = 'minecraft:stone_bricks';   pats = @('^s4_','^b2_','^s5_','^x_build') }
  valley      = @{ title = '🌾 绿谷'; icon = 'minecraft:wheat';          pats = @('^v0','^v1[0-2]','^x_planet_valley') }
  rust        = @{ title = '⚙️ 铁锈'; icon = 'minecraft:iron_ingot';     pats = @('^r0','^r1[0-4]','^x_planet_rust') }
  silicon     = @{ title = '🧠 硅火'; icon = 'minecraft:redstone';       pats = @('^s0','^s1[0-3]','^x_planet_silicon') }
  stellaris   = @{ title = '🚀 苍穹'; icon = 'minecraft:amethyst_shard'; pats = @('^c0','^c1[0-3]','^x_planet_stellaris') }
  interstellar = @{ title = '🌌 星际'; icon = 'minecraft:ender_pearl';   pats = @('^x_rail','^x_tour','^x_waystone','^x_sky','^x_stargate') }
  combat      = @{ title = '⚔️ 战斗'; icon = 'minecraft:netherite_sword'; pats = @('^x_boss','^e_','^b_') }
  knowledge   = @{ title = '📖 知识'; icon = 'minecraft:written_book';   pats = @('^g_','^k_','^x_overview') }
}

# ---- 读取所有 questlog 任务 ----
$all = @()
Get-ChildItem $qlDir -Filter *.json | ForEach-Object {
  try {
    $j = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    $j | Add-Member -NotePropertyName id -NotePropertyValue ([System.IO.Path]::GetFileNameWithoutExtension($_.Name)) -Force
    $all += $j
  } catch { Write-Host ("!! 跳过 " + $_.Name + ": " + $_.Exception.Message) }
}
Write-Host ("读取任务: " + $all.Count)

# ---- 归章 ----
function Get-Chapter([string]$id) {
  $short = $id -replace '^starciv_', ''
  foreach ($k in $chapters.Keys) {
    foreach ($p in $chapters[$k].pats) { if ($short -match $p) { return $k } }
  }
  return 'knowledge'
}

# ---- 分线（同章内多行布局）：combat 按 e_/b_/x_boss_ 三线 ----
function Get-Line([string]$cid, [string]$qid) {
  $short = $qid -replace '^starciv_', ''
  if ($cid -eq 'combat') {
    if ($short -match '^e_') { return 0 }
    if ($short -match '^b_') { return 1 }
    return 2
  }
  return 0
}

$grouped = @{}
foreach ($q in $all) {
  $cid = Get-Chapter $q.id
  if (-not $grouped.ContainsKey($cid)) { $grouped[$cid] = New-Object System.Collections.ArrayList }
  $null = $grouped[$cid].Add($q)
}

# ---- 生成章节 snbt ----
$orderIdx = 0
$totalQuests = 0
foreach ($cid in $chapters.Keys) {
  $qs = $grouped[$cid]
  if (-not $qs -or $qs.Count -eq 0) { continue }
  # 按 sort_order 排序
  $sorted = @($qs | Sort-Object { [int]($_.sort_order) })
  $meta = $chapters[$cid]
  $sb = New-Object System.Text.StringBuilder
  $null = $sb.AppendLine('{')
  $null = $sb.AppendLine('	default_hide_dependency_lines: false')
  $null = $sb.AppendLine('	default_quest_shape: ""')
  $null = $sb.AppendLine(('	filename: ' + (S $cid)))
  $null = $sb.AppendLine(('	id: ' + (S (UID $cid))))
  $null = $sb.AppendLine(('	icon: ' + (ItemBlock $meta.icon 1)))
  $null = $sb.AppendLine('	images: [ ]')
  $null = $sb.AppendLine(('	order_index: ' + $orderIdx))
  $null = $sb.AppendLine('	quest_links: [ ]')
  $null = $sb.AppendLine('	quests: [')
  # 布局：每条线内部链式依赖
  $lineUids = @{}
  $lineIdx = @{}
  $uidMap = @{}
  foreach ($q in $sorted) { $uidMap[$q.id] = (UID ('q:' + $q.id)) }
  foreach ($q in $sorted) {
    $lid = Get-Line $cid $q.id
    if (-not $lineIdx.ContainsKey($lid)) { $lineIdx[$lid] = 0; $lineUids[$lid] = $null }
    $idx = $lineIdx[$lid]
    $x = ($idx * 2).ToString() + '.0d'
    $y = ($lid * 2).ToString() + '.0d'
    $lineIdx[$lid] = $idx + 1
    $qid2 = (UID ('q:' + $q.id))
    # dependencies
    $dep = $lineUids[$lid]
    $depStr = if ($dep) { ('		dependencies: [' + (S $dep) + ']') } else { '		dependencies: [ ]' }
    # tasks
    $taskStrs = @()
    $tIdx = 0
    foreach ($o in @($q.objectives)) {
      $tid = UID ('t:' + $q.id + ':' + $tIdx)
      $tIdx++
      $n = [int]($o.required_amount)
      switch -Regex ($o.type) {
        'item_obtain|item_craft' { $taskStrs += ('{ id: ' + (S $tid) + ', type: "item", item: ' + (ItemBlock $o.item 1) + ', count: ' + $n + 'L }') }
        'visit_dimension' { $taskStrs += ('{ id: ' + (S $tid) + ', type: "dimension", dimension: ' + (S $o.dimension) + ' }') }
        'entity_kill' { $taskStrs += ('{ id: ' + (S $tid) + ', type: "kill", entity: ' + (S $o.entity) + ', value: ' + $n + 'L }') }
        'advancement' { $taskStrs += ('{ id: ' + (S $tid) + ', type: "advancement", advancement: ' + (S $o.advancement) + ' }') }
        default { $taskStrs += ('{ id: ' + (S $tid) + ', type: "checkmark" }') }
      }
    }
    if ($taskStrs.Count -eq 0) { $taskStrs += ('{ id: ' + (S (UID ('t:' + $q.id + ':0'))) + ', type: "checkmark" }') }
    # rewards
    $rewardStrs = @()
    $rIdx = 0
    foreach ($r in @($q.rewards)) {
      $rid = UID ('r:' + $q.id + ':' + $rIdx)
      $rIdx++
      if ($r.type -eq 'experience') { $rewardStrs += ('{ id: ' + (S $rid) + ', type: "xp", xp: ' + [int]$r.experience + ' }') }
      elseif ($r.type -eq 'item') { $rewardStrs += ('{ id: ' + (S $rid) + ', type: "item", item: ' + (ItemBlock $r.item ([int]$r.count)) + ' }') }
    }
    $null = $sb.AppendLine('		{')
    $null = $sb.AppendLine(('			id: ' + (S $qid2)))
    $null = $sb.AppendLine(('			title: ' + (S $q.title)))
    $null = $sb.AppendLine('			subtitle: ""')
    $null = $sb.AppendLine(('			description: ' + (S $q.description)))
    $null = $sb.AppendLine($depStr)
    $null = $sb.AppendLine(('			x: ' + $x))
    $null = $sb.AppendLine(('			y: ' + $y))
    $null = $sb.AppendLine(('			icon: ' + (ItemBlock $q.icon.item 1)))
    $null = $sb.AppendLine('			tasks: [')
    foreach ($t in $taskStrs) { $null = $sb.AppendLine(('				' + $t)) }
    $null = $sb.AppendLine('			]')
    $null = $sb.AppendLine('			rewards: [')
    foreach ($t in $rewardStrs) { $null = $sb.AppendLine(('				' + $t)) }
    $null = $sb.AppendLine('			]')
    $null = $sb.AppendLine('		}')
    $lineUids[$lid] = $qid2
    $totalQuests++
  }
  $null = $sb.AppendLine('	]')
  $null = $sb.AppendLine('}')
  [System.IO.File]::WriteAllText((Join-Path $chDir ($cid + '.snbt')), $sb.ToString(), $enc)
  $orderIdx++
  Write-Host ("章节 " + $cid + " 生成 " + $sorted.Count + " 任务")
}

# ---- data.snbt（必需）----
[System.IO.File]::WriteAllText((Join-Path $fqRoot 'data.snbt'), "{
	auto_accept_quests: false
	default_quest_shape: """"
	quest_file_version: 1L
	rewards: [ ]
	reward_tables: [ ]
}
", $enc)
Write-Host ("✔ FTB Quests 生成完成，共 " + $totalQuests + " 个任务 / " + $orderIdx + " 章")