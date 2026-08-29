# 生成 Questlog 任务（16 个：主线 11 + 知识指引 5）
$ErrorActionPreference = 'Stop'
$qdir = '.\pack\.minecraft\config\questlog\quests'
New-Item -ItemType Directory -Force -Path $qdir | Out-Null
Get-ChildItem $qdir -Filter *.json | Remove-Item -Force
$enc = New-Object System.Text.UTF8Encoding($false)

function New-Quest([string]$id, [string]$title, [string]$desc, [string]$bg, [string]$icon, [string[]]$pre, [object[]]$objs, [object[]]$rw) {
  $o = [ordered]@{ title = $title; description = $desc; icon = [ordered]@{ item = $icon } }
  if ($bg) { $o['background'] = $bg }
  $o['prerequisites'] = @($pre | ForEach-Object { [ordered]@{ type = 'questlog:quest_complete'; quest = ('questlog:' + $_) } })
  $o['objectives'] = $objs
  $o['rewards'] = $rw
  $o['toast_on_unlock'] = $true
  $o['toast_on_complete'] = $true
  [System.IO.File]::WriteAllText((Join-Path (Resolve-Path $qdir).Path ($id + '.json')), ($o | ConvertTo-Json -Depth 8), $enc)
  Write-Host ("  写 " + $id)
}
function AddAdv([object[]]$base, [string]$adv, [string]$name) {
  return @($base + @(@{ type = 'questlog:advancement'; advancement = $adv; required_amount = 1; name = ('成就·' + $name) }))
}

Write-Host "== 主线 11 =="
New-Quest 'starciv_q01_sprout' '绿谷 · 上古之种' '第一步：在绿谷星安家，找到并收集【上古之种】——它是铁锈纪元之前的文明遗物，也是一切晋升的起点。搜寻麦田与遗迹，独石碑脚下会有线索。' '星港档案馆的记录这样写道：绿谷星是四颗星球中唯一保有远古种子的世界。独石碑下的休眠舱里，上古文明留下了最后的遗产。捡起那颗种子，你就接过了文明的薪火。' 'starciv:ancient_seed' @() (AddAdv @(@{type='questlog:item_obtain'; item='starciv:ancient_seed'; required_amount=1; name='获取上古之种'}) 'starciv:agriculture/start' '绿谷初耕') @(@{type='questlog:item'; item='starciv:civ_essence'; count=2}, @{type='questlog:experience'; experience=20})
New-Quest 'starciv_q02_stellar_key' '绿谷 · 星门钥匙' '第二步：用文明精华、金锭与绿宝石铸造【星门钥匙】（配方见 JEI）。完成后前往绿谷星门。' '星门钥匙的作用被发现后，星港档案馆沸腾了——绿谷星门并非传说，而是通往其他三颗星球的唯一通道。铸造钥匙，就是向星空承诺：我们不会困守于此。' 'starciv:stellar_key' @('starciv_q01_sprout') (AddAdv @(@{type='questlog:item_craft'; item='starciv:stellar_key'; required_amount=1; name='铸造星门钥匙'}) 'starciv:agriculture/stellar_key' '星门开启') @(@{type='questlog:experience'; experience=50})
New-Quest 'starciv_q03_arrive_rust' '铁锈 · 踏上废土' '第三步：踏入铁锈星废土（星门传送），开始收集数据残骸。' '铁锈星曾是旧文明的工业心脏。如今锈蚀的大地仍回荡着机械的呓语——这里的每一块废铁里，都封存着一段被遗忘的科技。' 'minecraft:iron_ingot' @('starciv_q02_stellar_key') (AddAdv @(@{type='questlog:visit_dimension'; dimension='starciv:rustfall'; required_amount=1; name='抵达铁锈星'}) 'starciv:industry/arrival' '铁锈纪元') @(@{type='questlog:item'; item='starciv:data_slivers'; count=4})
New-Quest 'starciv_q04_biofuel' '铁锈 · 生物燃料' '第四步：合成【生物燃料罐】（上古之种 + 木炭装瓶），让锈蚀的工厂重新运转。' '上古之种的基因链解开了谜底——它能在任何环境下发酵。生物燃料罐是重启铁锈星抛光线的最短路径，也是绿谷农业与铁锈工业的第一次握手。' 'starciv:biofuel_canister' @('starciv_q03_arrive_rust') (AddAdv @(@{type='questlog:item_craft'; item='starciv:biofuel_canister'; required_amount=1; name='合成生物燃料罐'}) 'starciv:industry/fuel' '燃料革命') @(@{type='questlog:experience'; experience=80})
New-Quest 'starciv_q05_slivers' '铁锈 · 数据裂片' '第五步：收集 8 片【数据裂片】（紫水晶研磨或开采），破译旧世界知识。' '紫水晶是铁锈星少数未被氧化的晶体。研磨它们得到的数据裂片，记录了旧文明的生产参数——包括如何铸造更精密的零件。' 'starciv:data_slivers' @('starciv_q04_biofuel') (AddAdv @(@{type='questlog:item_obtain'; item='starciv:data_slivers'; required_amount=8; name='收集 8 片数据裂片'}) 'starciv:hidden/lost_tech' '失传科技') @(@{type='questlog:item'; item='starciv:precision_parts'; count=2})
New-Quest 'starciv_q06_arrive_silicon' '硅火 · 霓虹都市' '第六步：抵达硅火星的霓虹都市。这里的硅基自动工厂，将由你接管。' '硅火星是最接近旧文明巅峰的世界——整座都市仍亮着霓虹。档案馆的结论：这座城市从未关闭，它在等一个能读懂它的人。' 'minecraft:redstone' @('starciv_q05_slivers') (AddAdv @(@{type='questlog:visit_dimension'; dimension='starciv:silicon'; required_amount=1; name='抵达硅火星'}) 'starciv:information/arrival' '硅基纪元') @(@{type='questlog:experience'; experience=120})
New-Quest 'starciv_q07_precision' '硅火 · 精密零件' '第七步：锻造 4 个【精密零件】——穿梭机的核心部件，也是离开硅火星的先决条件。' '数据裂片终于化成了可用的设计图。精密零件是硅火星工业台的骄傲：只有这里的机床能保证亚毫米公差。' 'starciv:precision_parts' @('starciv_q06_arrive_silicon') (AddAdv @(@{type='questlog:item_craft'; item='starciv:precision_parts'; required_amount=4; name='锻造 4 个精密零件'}) 'starciv:information/chips' '芯片工坊') @(@{type='questlog:experience'; experience=200})
New-Quest 'starciv_q08_quantum' '硅火 · 量子核心' '第八步：组装【量子核心】。中央计算机群会在你脚下苏醒。' '量子核心是硅火都市的中枢神经。档案馆的秘档显示：当核心苏醒，星门的坐标库会展开——通往苍穹的路由此显现。' 'starciv:quantum_core' @('starciv_q07_precision') (AddAdv @(@{type='questlog:item_obtain'; item='starciv:quantum_core'; required_amount=1; name='组装量子核心'}) 'starciv:information/core' '量子之心') @(@{type='questlog:item'; item='starciv:warp_core'; count=1})
New-Quest 'starciv_q09_warp_engine' '硅火 · 跃迁引擎' '第九步：铸造【跃迁引擎】——抵达苍穹星的唯一钥匙。' '苍穹星不通过星门抵达，它需要跃迁。跃迁引擎由量子核心驱动，是硅火工业与间宇宙物理的结晶。' 'minecraft:firework_rocket' @('starciv_q08_quantum') (AddAdv @(@{type='questlog:item_craft'; item='starciv:warp_engine'; required_amount=1; name='铸造跃迁引擎'}) 'starciv:interstellar/engine' '跃迁引擎') @(@{type='questlog:experience'; experience=350})
New-Quest 'starciv_q10_arrive_stellaris' '苍穹 · 应许之地' '第十步：穿越苍穹之门，抵达悬浮大陆与水晶森林的苍穹星。' '苍穹星保存着文明的终极答案。传说首批文明在这里完成了“升华”——但他们也留下了守护者。' 'minecraft:nether_star' @('starciv_q09_warp_engine') (AddAdv @(@{type='questlog:visit_dimension'; dimension='starciv:stellaris'; required_amount=1; name='抵达苍穹星'}) 'starciv:interstellar/arrival' '苍穹纪元') @(@{type='questlog:item'; item='starciv:warp_core'; count=2})
New-Quest 'starciv_q11_final_boss' '苍穹 · 终局仪式' '最终步：击败远古造物【下界合金巨兽】，完成星港档案馆记载的终局仪式。' '守护者不是敌人，它是第一代文明留下的守门人。击败它并非征服，而是证明：新的文明已具备接过星火的资格。仪式完成之时，四颗星球的灯塔将同时亮起。' 'minecraft:netherite_ingot' @('starciv_q10_arrive_stellaris') (AddAdv @(@{type='questlog:entity_kill'; entity='cataclysm:netherite_monstrosity'; required_amount=1; name='击败下界合金巨兽'}) 'starciv:interstellar/contact' '接触造物') @(@{type='questlog:experience'; experience=1500}, @{type='questlog:item'; item='starciv:warp_core'; count=4})

Write-Host "== 知识指引 5（手册内容并入）=="
New-Quest 'starciv_g_guide' '指引 · 成为文明' '手册《星际文明编年史·探索手册》从这一刻并入任务书。阅读本章了解开局：四季节奏、性能建议、阶段规则。每阶段必须按顺序推进，否则星门不会响应。' '星港档案馆把四星文明的哲学写进了每一页。成为文明的第一步不是征服，而是理解——理解四季、理解机械、理解数据，最后理解星空。' 'minecraft:written_book' @('starciv_q01_sprout') @(@{type='questlog:item_obtain'; item='minecraft:book'; required_amount=1; name='拥有任意书籍'}) @(@{type='questlog:experience'; experience=10})
New-Quest 'starciv_g_agriculture' '指引 · 绿谷农业' '农业册并入任务书：四季系统决定耕种节奏——春播种、夏护养、秋丰收、冬温室（Botany Pots）。养蜂（Productive Bees）产基因样本；酿酒（Brewin and Chewin）建立村落经济；村民交易（Easy Villagers）织成贸易网络。农业是唯一能自我循环的起点。' '绿谷星的农田不是背景，而是文明的温床。档案馆始终相信：能种出粮食的文明，才配仰望星空。' 'minecraft:wheat' @('starciv_q02_stellar_key') @(@{type='questlog:item_craft'; item='minecraft:wheat'; required_amount=16; name='收获 16 个小麦'}) @(@{type='questlog:experience'; experience=25})
New-Quest 'starciv_g_industry' '指引 · 铁锈工业' '工业册并入任务书：Create 传动轴与 Belt 建材构建永动机城；Immersive Engineering 高压电网覆盖废土；Pollution of the Realms 的污染值提醒你——工业必须与自然和解。铁锈星的任务核心是产出与减排的平衡。' '铁锈星教会文明一件事：力量需要代价。但档案馆记录显示，旧文明正是败于对代价的傲慢。这一次，让机械服务于田园。' 'minecraft:piston' @('starciv_q04_biofuel') @(@{type='questlog:item_craft'; item='minecraft:piston'; required_amount=2; name='制作 2 个活塞'}) @(@{type='questlog:experience'; experience=30})
New-Quest 'starciv_g_information' '指引 · 硅火信息' '信息册并入任务书：Refined Storage 存储网络统御万物；Integrated Dynamics 以逻辑编程收发数据；CC:Tweaked 的电脑让整座都市自动化；AE2 的能量走廊是终局电网。硅火星的答案藏在比特与晶片之间。' '硅火文明几乎抵达了“上传”的境界——他们把自己写进了数据。档案馆警告：信息是有生命的，读懂它，但别被它吞噬。' 'minecraft:redstone_lamp' @('starciv_q07_precision') @(@{type='questlog:item_craft'; item='minecraft:redstone_lamp'; required_amount=1; name='制作红石灯'}) @(@{type='questlog:experience'; experience=40})
New-Quest 'starciv_g_interstellar' '指引 · 苍穹星际' '星际册并入任务书：Ad Astra 火箭与空间站搭建跨星球航线；跃迁引擎（warp engine）是通往苍穹的唯一载体；L_Ender 的 Cataclysm 的 Boss 是终局试炼。集齐四星科技的文明，才有资格举行终局仪式。' '苍穹星不是终点，而是起点。档案馆的最后一页写着：文明的轮回在苍穹完成，而薪火将永远传递。' 'minecraft:elytra' @('starciv_q10_arrive_stellaris') @(@{type='questlog:item_obtain'; item='starciv:warp_core'; required_amount=1; name='持有跃迁核心'}) @(@{type='questlog:experience'; experience=50})

Write-Host ""
$n = (Get-ChildItem $qdir -Filter *.json).Count
Write-Host ("✔ 共生成 " + $n + " 个任务")
$bad = 0
Get-ChildItem $qdir -Filter *.json | ForEach-Object { try { Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null } catch { Write-Host ("!! " + $_.Name + " " + $_.Exception.Message); $bad++ } }
Write-Host ("JSON 校验失败: " + $bad)