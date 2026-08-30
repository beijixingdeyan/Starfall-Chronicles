# 任务书 v4 追加：每星球 12-14 探索任务 + 装备图鉴 + 星球首领/精英
# 在 v3（48 任务）基础上追加 65 个，全部使用已验证 id（registry 枚举）
# 用法：先跑 generate_quests.ps1（v3 基础 48），再跑本脚本（追加）
$ErrorActionPreference = 'Stop'
$qroot = '.\pack\.minecraft\config\questlog'
$qdir = Join-Path $qroot 'quests'
$enc = New-Object System.Text.UTF8Encoding($false)

function New-Quest2([string]$id, [string]$title, [string]$desc, [string]$bg, [string]$icon, [object[]]$objs, [object[]]$rw, [string]$chapter, [int]$sort) {
  $o = [ordered]@{ title = $title; description = $desc; icon = [ordered]@{ item = $icon } }
  if ($bg) { $o['background'] = $bg }
  if ($chapter) { $o['chapter'] = $chapter }
  if ($sort -gt 0) { $o['sort_order'] = $sort }
  $o['objectives'] = $objs
  $o['rewards'] = $rw
  $o['toast_on_unlock'] = $true
  $o['toast_on_complete'] = $true
  [System.IO.File]::WriteAllText((Join-Path (Resolve-Path $qdir).Path ($id + '.json')), ($o | ConvertTo-Json -Depth 8), $enc)
}
function Ok([object[]]$rw) {
  return @(@{type='questlog:experience'; experience=30}) + $rw
}
function Obj([string]$t, [string]$i, [int]$n, [string]$name) {
  return @(@{ type = ('questlog:' + $t); item = $i; required_amount = $n; name = $name })
}
function ObjK([string]$entity, [string]$name) {
  return @(@{ type = 'questlog:entity_kill'; entity = $entity; required_amount = 1; name = $name })
}
function ObjD([string]$dim, [string]$name) {
  return @(@{ type = 'questlog:visit_dimension'; dimension = $dim; required_amount = 1; name = $name })
}

Write-Host "== 追加 · 绿谷篇 12 =="
New-Quest2 'starciv_v01_monolith' '绿谷 · 独石碑考古' '【位置】绿谷星门 (0,-100) 旁的独石碑 (26,-126)。
【目标】收集 2 份【文明精华】（上古之种成熟后加工）。
【要领】在独石碑周围仔细找休眠舱与隐藏箱，往往藏着更多种子。
【背景】独石碑是星港档案馆的入口，也是第一代文明留给绿谷的“遗嘱”。' '' 'starciv:civ_essence' (Obj 'item_obtain' 'starciv:civ_essence' 2 '收集 2 份文明精华') (Ok @()) 'dimensions' 76
New-Quest2 'starciv_v02_farm' '绿谷 · 四季农场' '【位置】出生地周边平原（河流两岸最肥沃）。
【目标】收获 16 个小麦；把农场扩到 2 块 9x9 田。
【要领】用锄头犁地+水渠灌溉；种一批留一批（循环播种）。
【背景】绿谷的四季（春种夏长秋收冬藏）让农业有了节奏——这是文明的第一课。' '' 'minecraft:wheat' (Obj 'item_craft' 'minecraft:wheat' 4 '收获 16 个小麦(合成4次)') (Ok @()) 'dimensions' 77
New-Quest2 'starciv_v03_greenhouse' '绿谷 · 温室花房' '【位置】绿谷河流南岸。
【目标】制作 2 个花盆 + 备 8 块玻璃，搭一座小温室。
【要领】玻璃封顶+花盆土培，冬天也能种作物（Botany Pots 更省心）。
【背景】温室是绿谷人对“四季”的第一次反抗：文明的本质是不向环境低头。' '' 'minecraft:flower_pot' (Obj 'item_craft' 'minecraft:flower_pot' 2 '制作 2 个花盆') (Ok @()) 'dimensions' 78
New-Quest2 'starciv_v04_field' '绿谷 · 田园酿造' '【位置】农田与蜂场之间。
【目标】收集 2 瓶蜂蜜 + 烤 4 个面包。
【要领】蜂蜜瓶右键蜂巢可得；面包用小麦三换一。
【背景】蜂蜜与面包是绿谷的“文明名片”——村民们都愿意为它们讨价还价。' '' 'minecraft:honey_bottle' (Obj 'item_obtain' 'minecraft:honey_bottle' 2 '收集 2 瓶蜂蜜') (Ok @()) 'dimensions' 79
New-Quest2 'starciv_v05_bees' '绿谷 · 花园蜂场' '【位置】花田中央。
【目标】制作 1 个蜂箱，收获 6 个蜜脾。
【要领】蜂箱放花田边，蜜脾蓄满后玻璃瓶收蜜；别徒手拆蜂巢。
【背景】蜂场让农场第一次“自动化”：花粉传播由蜜蜂承包。' '' 'minecraft:beehive' (Obj 'item_craft' 'minecraft:beehive' 1 '制作蜂箱') (Ok @()) 'dimensions' 80
New-Quest2 'starciv_v06_river' '绿谷 · 河流生态' '【位置】绿谷新开凿的流动河流（出生点南侧，约 0,70,-40 起）。
【目标】收集 4 个睡莲 + 钓上 3 条鳕鱼。
【要领】睡莲漂在水面直接捡；钓鱼挂上鱼竿耐心等（水下有鳄鱼！）。
【背景】河流是绿谷的生命线：灌溉、运输、风景，缺一不可。' '' 'minecraft:lily_pad' (Obj 'item_obtain' 'minecraft:lily_pad' 4 '收集 4 个睡莲') (Ok @()) 'dimensions' 81
New-Quest2 'starciv_v07_mines' '绿谷 · 矿脉探险' '【位置】绿谷地下（河流下游石灰岩山体）。
【目标】挖到 3 颗绿宝石 + 8 块金锭。
【要领】绿宝石在深山地层常见；下矿带火把，岔路口做标记。
【背景】绿谷的矿脉太平和了——真正的矿藏在铁锈星等着你。' '' 'minecraft:emerald' (Obj 'item_obtain' 'minecraft:emerald' 3 '收集 3 颗绿宝石') (Ok @()) 'dimensions' 82
New-Quest2 'starciv_v08_village' '绿谷 · 交易村落' '【位置】周围村庄（出生点任意方向 300-800 格，有小地图指引）。
【目标】与村民交易，攒下 8 颗绿宝石。
【要领】种田卖粮最划算；村民价格会波动，多对比。
【背景】交易网络是文明的稳定器——档案馆认为：绿谷的和平来自“谁都离不开谁”。' '' 'minecraft:emerald' (Obj 'item_obtain' 'minecraft:emerald' 8 '交易攒下 8 颗绿宝石') (Ok @()) 'dimensions' 83
New-Quest2 'starciv_v09_archive' '绿谷 · 星港档案馆' '【位置】独石碑 (26,-126)。
【目标】制作 3 本书（含《编年史》用）。
【要领】书=纸×3+皮革；档案馆周围常有旧书架残骸。
【背景】档案馆的电子库早已断电，但纸质书页永远不会过期。' '' 'minecraft:book' (Obj 'item_craft' 'minecraft:book' 3 '制作 3 本书') (Ok @()) 'dimensions' 84
New-Quest2 'starciv_v10_deepsea' '绿谷 · 深海遗迹' '【位置】绿谷海沟（出生点以北的大海深处）。
【目标】收集 8 个海晶碎片（海底神殿/遗迹宝箱）+ 击败 2 只深潜者（deepling）。
【要领】水下呼吸药水+夜视；带盾防三叉戟。
【背景】海下沉睡着第一代文明的水下前哨——深潜者仍在守护它们。' '' 'minecraft:prismarine_shard' (Obj 'item_obtain' 'minecraft:prismarine_shard' 8 '收集 8 个海晶碎片') (Ok @()) 'dimensions' 85
New-Quest2 'starciv_v11_deepling' '绿谷 · 精英首领：深潜蛮兵' '【位置】绿谷海沟深处（深潜者巢穴）。
【目标】击败 1 只【深潜蛮兵】（deepling brute）。
【要领】它比普通深潜者壮一圈、攻击附带击退；水战吃亏，引到浅滩打。
【掉落】海底材料的稳定来源之一。
【背景】档案：深潜蛮兵是水下前哨的“警长”，任何闯入者都得先过它这关。' '' 'minecraft:prismarine_bricks' (ObjK 'cataclysm:deepling_brute' '击败深潜蛮兵') (Ok @()) 'dimensions' 86
New-Quest2 'starciv_v12_ring' '绿谷 · 地标环游' '【位置】晨曦花园城堡 (60,-250)。
【目标】备 4 颗橡树苗（城堡花园补种用）+ 亲自登上主塔观景台。
【要领】城堡护城河对岸正南是全景机位；夜里灯火全亮最美。
【背景】环游地标不是观光——是让新文明记得：自己从哪里来。' '' 'minecraft:oak_sapling' (Obj 'item_obtain' 'minecraft:oak_sapling' 4 '准备 4 颗橡树苗') (Ok @()) 'dimensions' 87

Write-Host "== 追加 · 铁锈篇 14 =="
New-Quest2 'starciv_r01_scrap' '铁锈 · 废土开荒' '【位置】铁锈星门 (200,200) 周边废墟。
【目标】收集 24 块铁锭（废铁熔炼/矿脉）。
【要领】废墟里的铁栅栏/铁块可挖了熔炼；深矿层铁最多。
【背景】在铁锈星，铁不是矿产——它是骸骨。大地记得每一座工厂。' '' 'minecraft:iron_ingot' (Obj 'item_obtain' 'minecraft:iron_ingot' 24 '收集 24 块铁锭') (Ok @()) 'dimensions' 88
New-Quest2 'starciv_r02_amethyst' '铁锈 · 紫水晶矿脉' '【位置】铁锈地下（灯塔 480,460 周边岩层最密集）。
【目标】采集 24 枚紫水晶碎片。
【要领】精准采集更好的整块；带足镐，洞穴蝙蝠成群。
【背景】紫水晶是铁锈星少数没被氧化的晶体——旧文明用它们存储数据。' '' 'minecraft:amethyst_shard' (Obj 'item_obtain' 'minecraft:amethyst_shard' 24 '采集 24 枚紫水晶碎片') (Ok @()) 'dimensions' 89
New-Quest2 'starciv_r03_slivers' '铁锈 · 数据深挖' '【位置】铁锈各遗迹的档案室/矿洞。
【目标】收集 16 片【数据裂片】。
【要领】紫水晶研磨成裂片；遗迹宝箱也常有存货。
【背景】每片裂片都是一段生产参数——读得懂它们，就接过了旧文明的图纸。' '' 'starciv:data_slivers' (Obj 'item_obtain' 'starciv:data_slivers' 16 '收集 16 片数据裂片') (Ok @()) 'dimensions' 90
New-Quest2 'starciv_r04_shafts' '铁锈 · 传动工程课' '【位置】铁锈中转站（星门附近厂房）。
【目标】制作 16 根【传动轴】（Create）。
【要领】一根轴带不动两条产线——学会用齿轮箱分速。
【背景】抛光线重启的第一步，就是把“动力”重新接回废土。' '' 'create:shaft' (Obj 'item_craft' 'create:shaft' 16 '制作 16 根传动轴') (Ok @()) 'dimensions' 91
New-Quest2 'starciv_r05_pipes' '铁锈 · 管网自动化' '【位置】铁锈厂房与仓库之间。
【目标】制作 4 个【物品管道】（Pipez）收拢产线。
【要领】管道右键切输入/输出；矿物都往一个箱子汇。
【背景】物资自己流动的那一刻，铁锈星才真正“活”了过来。' '' 'pipez:item_pipe' (Obj 'item_craft' 'pipez:item_pipe' 4 '制作 4 个物品管道') (Ok @()) 'dimensions' 92
New-Quest2 'starciv_r06_blast' '铁锈 · 高炉群巡礼' '【位置】灯塔 (480,460) 远方的高炉群。
【目标】储备 32 块煤 + 亲自站在高炉群中央听一次“轰鸣”。
【要领】煤在矿脉/废墟仓库；高炉群是旧文明的墓碑，也是你的熔炉。
【背景】站在高炉群中央，你才会明白旧文明为什么能把天空染锈。' '' 'minecraft:coal' (Obj 'item_obtain' 'minecraft:coal' 32 '储备 32 块煤') (Ok @()) 'dimensions' 93
New-Quest2 'starciv_r07_provision' '铁锈 · 哨站补给' '【位置】废土哨站 (140,130)。
【目标】烤 8 块牛排（狩猎牛/马）。
【要领】废土草场有野牛（Alex 的动物）；篝火/烟熏炉更省燃料。
【背景】哨站的意义：在废土维持“人吃得饱”这条底线。' '' 'minecraft:cooked_beef' (Obj 'item_craft' 'minecraft:cooked_beef' 8 '烤 8 块牛排') (Ok @()) 'dimensions' 94
New-Quest2 'starciv_r08_cleanup' '铁锈 · 污染治理' '【位置】高炉群与哨站周边。
【目标】种下 8 颗橡树苗（绿植抗污染）。
【要领】污染值见右上角指示器；种树+过滤器能压回安全线。
【背景】旧文明死于对代价的傲慢。这一次，让机械服务于田园。' '' 'minecraft:oak_sapling' (Obj 'item_obtain' 'minecraft:oak_sapling' 8 '种 8 颗橡树苗') (Ok @()) 'dimensions' 95
New-Quest2 'starciv_r09_night' '铁锈 · 夜袭防线' '【位置】铁锈星任意据点（夜里最危险）。
【目标】击杀 10 只僵尸（夜袭者）。
【要领】夜里废土的僵尸游荡成片；据点插满火把+铁门。
【背景】铁锈星的夜，属于亡灵与变异体——它们比地表的锈更贪婪。' '' 'minecraft:rotten_flesh' (ObjK 'minecraft:zombie' '击杀 10 只僵尸') (Ok @()) 'dimensions' 96
New-Quest2 'starciv_r10_lantern' '铁锈 · 灯塔守望' '【位置】铁锈灯塔 (480,460)。
【目标】制作 6 个灯笼，亲手把灯塔点亮一次。
【要领】灯笼=火把+8铁粒；塔顶灯室有隐藏箱。
【背景】灯塔不是为了照亮路，是为了告诉星空：这里还亮着。' '' 'minecraft:lantern' (Obj 'item_craft' 'minecraft:lantern' 6 '制作 6 个灯笼') (Ok @()) 'dimensions' 97
New-Quest2 'starciv_r11_transport' '铁锈 · 矿车铁路' '【位置】星门与高炉群之间。
【目标】制作 2 辆矿车 + 16 格铁轨，铺一段运输线。
【要领】坡道用动力铁轨+红石火把；矿车运煤运矿都行。
【背景】铁路是废土物流的脊梁——旧文明的铁轨还埋在锈土里。' '' 'minecraft:minecart' (Obj 'item_craft' 'minecraft:minecart' 2 '制作 2 辆矿车') (Ok @()) 'dimensions' 98
New-Quest2 'starciv_r12_forge' '铁锈 · 废土锻甲' '【位置】任意锻造站。
【目标】锻造 1 件铁胸甲 + 1 把铁剑（进阶：黑钢参见【装备】页签）。
【要领】铁锭+工作台；附魔台插书架更香。
【背景】废土的铁皮就是新文明的甲胄——先活下来，再谈理想。' '' 'minecraft:iron_chestplate' (Obj 'item_craft' 'minecraft:iron_chestplate' 1 '锻造铁胸甲') (Ok @()) 'dimensions' 99
New-Quest2 'starciv_r13_bunker' '铁锈 · 地下避难所' '【位置】铁锈城废墟的地下（地表大洞下去）。
【目标】备 32 根火把点亮一层避难所。
【要领】废城地下藏着旧文明的生活区——火把是文明回归的标志。
【背景】黑暗会先于怪物吞掉一切。点亮它。' '' 'minecraft:torch' (Obj 'item_craft' 'minecraft:torch' 32 '做 32 根火把') (Ok @()) 'dimensions' 100
New-Quest2 'starciv_r14_draugr' '铁锈 · 精英首领：皇家尸鬼' '【位置】铁锈地下王陵/废城地宫。
【目标】击败 1 只【皇家尸鬼】（royal draugr）。
【要领】它会呼召普通尸鬼+瞬移斩；先清小怪再集火，火锅底料别省。
【掉落】废土系材料。
【背景】尸鬼是旧文明武装部队的残骸——皇家尸鬼则是它们的“将军”。' '' 'minecraft:bone' (ObjK 'cataclysm:royal_draugr' '击败皇家尸鬼') (Ok @()) 'dimensions' 101

Write-Host "== 追加 · 硅火篇 13 =="
New-Quest2 'starciv_s01_neon' '硅火 · 霓虹街市' '【位置】硅火星门 (-300,150) 落地即霓虹街。
【目标】收集 8 块品红染色玻璃 + 4 份品红染料（霓虹装饰）。
【要领】都市废料箱里常有；玻璃匠铺可换。
【背景】硅火的霓虹不是装饰——是这座都市仍在呼吸的证明。' '' 'minecraft:magenta_stained_glass' (Obj 'item_obtain' 'minecraft:magenta_stained_glass' 8 '收集 8 块品红玻璃') (Ok @()) 'dimensions' 102
New-Quest2 'starciv_s02_relay' '硅火 · 数据中继' '【位置】都市街道地下的管线井。
【目标】收集 8 片数据裂片 + 制作 2 个红石灯。
【要领】井盖下藏着旧网线的备份；红石灯是硅火的路灯。
【背景】硅火把整座城市写进了数据——纸面档案在这里早已消失。' '' 'starciv:data_slivers' (Obj 'item_obtain' 'starciv:data_slivers' 8 '收集 8 片数据裂片') (Ok @()) 'dimensions' 103
New-Quest2 'starciv_s03_circuit' '硅火 · 电路工坊' '【位置】都市任意工坊。
【目标】备 32 份红石粉 + 制作 4 个红石中继器 + 2 个比较器。
【要领】红石在都市地下矿脉/旧机房；中继器是信号高速公路。
【背景】电路是硅火的语言——读懂它，你就能让整座都市为你工作。' '' 'minecraft:redstone' (Obj 'item_obtain' 'minecraft:redstone' 32 '备 32 份红石粉') (Ok @()) 'dimensions' 104
New-Quest2 'starciv_s04_energy' '硅火 · 能量走廊' '【位置】中央计算机群外围的玻璃长廊。
【目标】制作 1 个红石块 + 收集 16 块石英。
【要领】能量走廊是都市的“血管”；红石块做成枢纽。
【背景】石英与红石在硅火体内同流——这就是它不熄灯的代价。' '' 'minecraft:redstone_block' (Obj 'item_craft' 'minecraft:redstone_block' 1 '制作红石块') (Ok @()) 'dimensions' 105
New-Quest2 'starciv_s05_amethyst' '硅火 · 紫晶工艺' '【位置】都市外围岩层。
【目标】采 32 枚紫水晶碎片 + 做 4 块遮光玻璃。
【要领】遮光玻璃挡霓虹刺眼；紫水晶是硅火的地标建材。
【背景】硅火人认为紫水晶里有“光”——他们把整座城照成了水晶宫。' '' 'minecraft:amethyst_shard' (Obj 'item_obtain' 'minecraft:amethyst_shard' 32 '采 32 枚紫水晶碎片') (Ok @()) 'dimensions' 106
New-Quest2 'starciv_s06_skyline' '硅火 · 都市瞭望' '【位置】霓虹商栈 (-220,210) 高层露台。
【目标】备 16 块玻璃 + 居高俯瞰整座都市（截图留念）。
【要领】玻璃做观景台护栏；日落时霓虹最美。
【背景】站在都市之巅，你会理解旧文明为何如此骄傲——也会理解它为何坠落。' '' 'minecraft:glass' (Obj 'item_obtain' 'minecraft:glass' 16 '备 16 块玻璃') (Ok @()) 'dimensions' 107
New-Quest2 'starciv_s07_trade' '硅火 · 商栈贸易' '【位置】霓虹商栈 (-220,210)。
【目标】集 16 颗绿宝石（以货易货/任务收入）。
【要领】裂片换绿宝石最划算；商栈收紫水晶。
【背景】硅火的贸易法则：信息即货币——谁读得懂数据，谁就富有。' '' 'minecraft:emerald' (Obj 'item_obtain' 'minecraft:emerald' 16 '集 16 颗绿宝石') (Ok @()) 'dimensions' 108
New-Quest2 'starciv_s08_quantum' '硅火 · 量子实验室' '【位置】中央计算机群内部实验室。
【目标】持有 1 个【跃迁核心】检测量子环境（主线⑧后即成）。
【要领】核心在主线里会用到；此任务只需“持有”。
【背景】量子实验室门上写着：进来之前，请先忘掉经典物理。' '' 'starciv:warp_core' (Obj 'item_obtain' 'starciv:warp_core' 1 '持有跃迁核心') (Ok @()) 'dimensions' 109
New-Quest2 'starciv_s09_computer' '硅火 · 中央计算机群' '【位置】都市核心（落点东北，最高的玻璃塔群）。
【目标】抵达中央计算机群 + 备 4 个红石灯。
【要领】主线⑧⑨在此推进；红石灯是“开机”的信号。
【背景】这座计算机群里，可能还运行着第一代文明最后的进程。' '' 'minecraft:redstone_lamp' (Obj 'item_obtain' 'minecraft:redstone_lamp' 4 '备 4 个红石灯') (Ok @()) 'dimensions' 110
New-Quest2 'starciv_s10_witch' '硅火 · 霓虹夜市' '【位置】都市夜间的巷道。
【目标】击败 2 只女巫 + 收集 8 份萤石粉。
【要领】女巫泼药水要闪避；萤石粉照亮夜市。
【背景】硅火的夜晚属于女巫与幽灵程序——她们在旧机房徘徊。' '' 'minecraft:glowstone_dust' (Obj 'item_obtain' 'minecraft:glowstone_dust' 8 '收集 8 份萤石粉') (Ok @()) 'dimensions' 111
New-Quest2 'starciv_s11_redstone' '硅火 · 红石奇观' '【位置】都市工坊区。
【目标】制作 4 个活塞 + 2 个粘性活塞。
【要领】粘性活塞用粘液球；组合起来可以做都市机关。
【背景】硅火的工程师把红石玩成了艺术——访客称它为“会思考的都市”。' '' 'minecraft:piston' (Obj 'item_craft' 'minecraft:piston' 4 '制作 4 个活塞') (Ok @()) 'dimensions' 112
New-Quest2 'starciv_s12_berserker' '硅火 · 精英首领：烈焰狂战士' '【位置】硅火地下熔炉区（都市正下方岩洞）。
【目标】击败 1 只【烈焰狂战士】（ignited berserker）。
【要领】它被点燃后攻击翻倍——先打断它的点燃动作（远程打断）。
【掉落】烈焰系材料（通向炎之王试炼）。
【背景】狂战士是都市最后一批“火卫兵”——它们在熔炉区守了千年。' '' 'minecraft:blaze_rod' (ObjK 'cataclysm:ignited_berserker' '击败烈焰狂战士') (Ok @()) 'dimensions' 113
New-Quest2 'starciv_s13_firework' '硅火 · 霓虹庆典' '【位置】中央广场。
【目标】制作 4 枚烟花火箭 + 收集 8 颗荧光浆果。
【要领】烟花=火药+纸+染料；庆典时广场会亮成星河。
【背景】旧文明每年都在这一天放烟花——庆祝“续命成功”。千年后，烟花还在。' '' 'minecraft:firework_rocket' (Obj 'item_craft' 'minecraft:firework_rocket' 4 '制作 4 枚烟花') (Ok @()) 'dimensions' 114

Write-Host "== 追加 · 苍穹篇 12 =="
New-Quest2 'starciv_c01_islands' '苍穹 · 悬浮岛纵览' '【位置】苍穹星门 (120,-260) 落地环视。
【目标】抵达苍穹星 + 采 8 枚紫水晶碎片。
【要领】悬浮岛之间有吊桥/滑翔通道；掉进云海会重生到星门。
【背景】苍穹是四星中最不像“星球”的——它更像文明的陵园与摇篮。' '' 'minecraft:amethyst_shard' (ObjD 'starciv:stellaris' '抵达苍穹星') (Ok @()) 'dimensions' 115
New-Quest2 'starciv_c02_crystals' '苍穹 · 晶体森林' '【位置】晶体平原（星门东南大面积发光区）。
【目标】采 32 枚紫水晶碎片 + 4 块紫水晶块。
【要领】晶体森林夜里发光像星河；穿好装备，巨兽巢穴就在深处。
【背景】晶体森林记录着星光的形状——每枚水晶都是一束被收纳的光。' '' 'minecraft:amethyst_block' (Obj 'item_obtain' 'minecraft:amethyst_shard' 32 '采 32 枚紫水晶碎片') (Ok @()) 'dimensions' 116
New-Quest2 'starciv_c03_airship' '苍穹 · 空艇甲板' '【位置】苍穹空艇 (300,-580)。
【目标】备 32 块橡木木板 + 1 个木桶（登艇补给）。
【要领】空艇是悬浮大陆的“港口”；甲板黄昏拍照绝美。
【背景】档案馆的开工记录：这艘空艇是最后一艘，再也没有下一艘了。' '' 'minecraft:oak_planks' (Obj 'item_obtain' 'minecraft:oak_planks' 32 '备 32 块橡木板') (Ok @()) 'dimensions' 117
New-Quest2 'starciv_c04_shrine' '苍穹 · 星界祭坛' '【位置】晶体森林间的荒废祭坛。
【目标】制作 4 根末地烛 + 集 8 颗末影珍珠。
【要领】祭坛点燃后，附近会聚集末影生物——注意背后。
【背景】祭坛不是崇拜——是第一代文明向“回归”发出信号的电台。' '' 'minecraft:end_rod' (Obj 'item_craft' 'minecraft:end_rod' 4 '制作 4 根末地烛') (Ok @()) 'dimensions' 118
New-Quest2 'starciv_c05_glide' '苍穹 · 云海滑翔' '【位置】任意悬浮岛边缘。
【目标】集 3 片幻翼膜（为鞘翅做准备）。
【要领】幻翼在你连续三天不睡觉时出现；或去末地城找鞘翅。
【背景】滑翔是一项“苍穹特供”运动——风里裹着晶尘，呼吸都是甜的。' '' 'minecraft:phantom_membrane' (Obj 'item_obtain' 'minecraft:phantom_membrane' 3 '集 3 片幻翼膜') (Ok @()) 'dimensions' 119
New-Quest2 'starciv_c06_void' '苍穹 · 虚空残片' '【位置】悬浮岛边缘的虚空裂缝附近。
【目标】收集 4 个【虚空碎片】（cataclysm）。
【要领】虚空的裂缝里偶有碎片飘出；小心别掉进去。
【背景】虚空碎片是第一代文明“跃迁”留下的废料——也是终局材料的线索。' '' 'cataclysm:void_shard' (Obj 'item_obtain' 'cataclysm:void_shard' 4 '收集 4 个虚空碎片') (Ok @()) 'dimensions' 120
New-Quest2 'starciv_c07_netherite' '苍穹 · 终局材料' '【位置】苍穹晶体平原深层矿/末地。
【目标】熔炼 2 块远古残骸 + 合成 1 块下界合金锭。
【要领】远古残骸在下界深处（y≈15）；灵魂沙谷更富。
【背景】下界合金不是挖出来的——是“淬”出来的。苍穹守护者的甲壳也是这么来的。' '' 'minecraft:netherite_scrap' (Obj 'item_obtain' 'minecraft:netherite_scrap' 2 '熔 2 块远古残骸') (Ok @()) 'dimensions' 121
New-Quest2 'starciv_c08_serpent' '苍穹 · 风暴巨蛇' '【位置】晶体森林上空的雷暴云里。
【目标】击败 1 只【风暴巨蛇】（storm serpent）。
【要领】它盘踞云端，喷吐闪电；用弓箭+盾牌，落地时集火。
【掉落】雷暴系材料。
【背景】风暴巨蛇是苍穹大气层的“守卫”——档案馆叫它天气本身。' '' 'minecraft:lightning_rod' (ObjK 'cataclysm:storm_serpent' '击败风暴巨蛇') (Ok @()) 'dimensions' 122
New-Quest2 'starciv_c09_prepare' '苍穹 · 终局备战' '【位置】任意据点。
【目标】备 2 个金苹果 + 1 个不死图腾（终局前准备）。
【要领】金苹果=金锭+苹果；图腾去林地府邸/掠夺者队长。
【背景】准备是胜利的一半——终局仪式没有第二次机会。' '' 'minecraft:golden_apple' (Obj 'item_craft' 'minecraft:golden_apple' 2 '备 2 个金苹果') (Ok @()) 'dimensions' 123
New-Quest2 'starciv_c10_golem' '苍穹 · 精英首领：末影傀儡' '【位置】晶体森林边缘的古机械坟场。
【目标】击败 1 只【末影傀儡】（ender golem）。
【要领】它会瞬移+召唤末影人；保持移动，用喷溅治疗别停。
【掉落】苍穹中级材料。
【背景】末影傀儡是第一代文明最后一批自动兵器——它们仍按“灭绝异形”的指令运转。' '' 'cataclysm:enderite_ingot' (ObjK 'cataclysm:ender_golem' '击败末影傀儡') (Ok @()) 'dimensions' 124
New-Quest2 'starciv_c11_watcher' '苍穹 · 首领试炼：先驱者' '【位置】苍穹最高悬浮岛的穹顶。
【目标】击败 1 只【先驱者】（the harbinger）。
【要领】它掌握空间法术（传送+裂隙）；Boss 战要带珍珠与图腾，分阶段打。
【掉落】先驱者遗物——终局前的最终试炼之一。
【背景】先驱者是“离开地球”的第一个文明成员——也是最后一个。它回来了。' '' 'cataclysm:void_core' (ObjK 'cataclysm:the_harbinger' '击败先驱者') (Ok @()) 'dimensions' 125
New-Quest2 'starciv_c12_pilgrimage' '苍穹 · 应许巡航' '【位置】四星各据点。
【目标】持有 2 块【末地锭】（enderite ingot）纪念远征。
【要领】末地锭=末影珍珠+合金废料（JEI 查配方）。
【背景】巡航的意义：把四颗星球的记忆，铸成一块属于新文明的金属。' '' 'cataclysm:enderite_ingot' (Obj 'item_obtain' 'cataclysm:enderite_ingot' 2 '持有 2 块末地锭') (Ok @()) 'dimensions' 126

Write-Host "== 追加 · 星际总览 4 =="
New-Quest2 'starciv_x_rail' '星际 · 轨道运输' '【位置】绿谷→铁锈星门沿线。
【目标】铺 24 格铁轨（或修一条你们之间的“大动脉”）。
【要领】Create 列车（蒸汽铁路）可在铁轨上跑：动力机车+车厢。
【背景】第一代文明的四星物流网靠的也是铁路——历史在重演，这一次更温柔。' '' 'minecraft:rail' (Obj 'item_craft' 'minecraft:rail' 24 '铺 24 格铁轨') (Ok @()) 'dimensions' 127
New-Quest2 'starciv_x_tour' '星际 · 四星特产' '【位置】四星各特产区。
【目标】集齐四星特产：种子 / 铁锭 / 红石 / 紫水晶碎片（各 4）。
【要领】特产=四星文明的“名片”；交集处可以做贸易中心。
【背景】文明因交换而伟大——四星特产汇聚的地方，就是新文明的星港。' '' 'starciv:ancient_seed' (Obj 'item_obtain' 'starciv:ancient_seed' 1 '持有上古之种') (Ok @()) 'dimensions' 128
New-Quest2 'starciv_x_waystone' '星际 · 路标网络' '【位置】各地标/驿站的路标石。
【目标】激活 4 个路标（waystone 右键登记）。
【要领】路标激活后可互相传送；地图上能直观看到已激活路标。
【背景】路标网络是文明的地图——让四颗星球之间不再有“迷路”。' '' 'waystones:waystone' (Obj 'item_obtain' 'waystones:waystone' 1 '激活路标') (Ok @()) 'dimensions' 129
New-Quest2 'starciv_x_sky' '星际 · 登天计划' '【位置】苍穹空艇甲板。
【目标】制作 1 个望远镜（spyglass）+ 遥望下方星球。
【要领】望远镜=铜锭+紫水晶（原版合成）。
【背景】从苍穹看绿谷，只是一粒发光的种子。文明的高度，就是这样拉开的。' '' 'minecraft:spyglass' (Obj 'item_craft' 'minecraft:spyglass' 1 '制作望远镜') (Ok @()) 'dimensions' 130

Write-Host "== 追加 · 装备图鉴 4（combat）=="
New-Quest2 'starciv_e_melee' '武器 · 黑钢近战' '【武器图鉴：黑钢系】（Cataclysm）
【是什么】黑钢剑/斧/镐/锹——废土废钢锻造的原生武器，中前期最强平民武器。
【怎么获得】黑钢锭（废铁+煤）在工作台/锻造台制成；JEI 可查全配方。
【对比】黑钢剑≈钻石剑的下位替身，但附魔后性价比极高。
【目标】打造 1 把【黑钢剑】。
【背景】档案馆武器栏第一行：黑钢不锋利，但够硬。废土信奉硬度。' '' 'cataclysm:black_steel_sword' (Obj 'item_obtain' 'cataclysm:black_steel_sword' 1 '获得黑钢剑') (Ok @()) 'combat' 140
New-Quest2 'starciv_e_ranged' '武器 · 诅咒之弓' '【武器图鉴：诅咒之弓】（Cataclysm）
【是什么】发射诅咒箭矢的远程武器，附带穿透/凋零效果，Boss 战首选。
【怎么获得】击杀【远古残骸】等废土首领掉落，或摧毁其残骸寻宝。
【提示】配合火焰箭/多普勒箭更猛——远程职业的毕业级武器之一。
【目标】获得 1 把【诅咒之弓】。
【背景】警句：弓弦上刻着一行字——“每一次命中，都在偿还旧债。”' '' 'cataclysm:cursed_bow' (Obj 'item_obtain' 'cataclysm:cursed_bow' 1 '获得诅咒之弓') (Ok @()) 'combat' 141
New-Quest2 'starciv_e_armor' '防具 · 熔火重甲' '【防具图鉴：熔火系】（Cataclysm，炎之王掉落的材料）
【是什么】头盔/胸甲/护腿/靴子 + 熔火披风/鞘翅胸甲——火焰附魔重甲。
【怎么获得】用【熔火锭】（炎之王 ignis 掉落）锻造全套。
【数据】护甲值顶配；自带抗火附魔，适合火战与下界远征。
【目标】锻造 1 件【熔火胸甲】。
【背景】档案馆：穿熔火甲的人和炎之王之间，只有一炉之隔。' '' 'cataclysm:ignitium_chestplate' (Obj 'item_obtain' 'cataclysm:ignitium_chestplate' 1 '获得熔火胸甲') (Ok @()) 'combat' 142
New-Quest2 'starciv_e_gauntlet' '装备 · 圣卫拳套' '【装备图鉴：拳套与护盾】（Cataclysm）
【是什么】圣卫拳套/守护拳套/漩涡拳套——副手近战格挡系；
　　　　蔚蓝海盾——水下战斗防线；
　　　　烈焰壁垒——火战护盾。
【怎么获得】深海/烈焰首领掉落（利维坦、炎之王系）。
【提示】拳套格挡不耗耐久；护盾可附魔“荆棘”反弹。
【目标】获得 1 个【圣卫拳套】（gauntlet of guard）。
【背景】拳套上刻着守卫者的誓言：我挡住的不只是攻击，还有你们的恐惧。' '' 'cataclysm:gauntlet_of_guard' (Obj 'item_obtain' 'cataclysm:gauntlet_of_guard' 1 '获得圣卫拳套') (Ok @()) 'combat' 143

Write-Host "== 追加 · 星球首领 3（combat）=="
New-Quest2 'starciv_b_remnant' '首领 · 远古残骸（铁锈）' '【Boss 档案：远古残骸】（ancient remnant）
【位置】铁锈星沙漠/废土巨型骸骨区（灯塔西南沙漠）。
【外观】巨型白骨甲虫机甲，喷射毒针与沙暴。
【打法】
  ① 沙暴阶段找岩柱遮挡
  ② 近身喷毒转圈躲
  ③ 掉落：诅咒之弓 + 远古金属锭（ancient metal）
【目标】击败 1 次。
【剧情】它守卫着旧文明最后的矿脉——铁锈星的“地心钥匙”。' '' 'cataclysm:ancient_metal_ingot' (ObjK 'cataclysm:ancient_remnant' '击败远古残骸') (Ok @()) 'combat' 144
New-Quest2 'starciv_b_ignis' '首领 · 炎之王（硅火）' '【Boss 档案：炎之王】（ignis）
【位置】硅火地下熔炉核心（都市正下方深处）。
【外观】烈焰巨兽：吐火、召陨石、点燃全场。
【打法】
  ① 保持距离躲火浪
  ② 陨石阶段逃到霓虹柱后
  ③ 掉落：熔火锭（ignitium）+ 烈焰壁垒
【目标】击败 1 次。
【剧情】炎之王是都市“供电”的源头——它休眠时，硅火才能点亮。' '' 'cataclysm:ignitium_ingot' (ObjK 'cataclysm:ignis' '击败炎之王') (Ok @()) 'combat' 145
New-Quest2 'starciv_b_watcher' '首领 · 虚空潜视（苍穹）' '【Boss 档案：虚空潜视】（the watcher）
【位置】苍穹晶体森林最深处的虚空柱。
【外观】悬浮的巨大眼球：空间裂隙、激光、召唤虚空生物。
【打法】
  ① 打掉召唤物优先，否则场地失控
  ② 激光前摇明显，侧向走位
  ③ 掉落：虚空核心/碎片
【目标】击败 1 次。
【剧情】它不是怪物——它是一只“眼睛”。第一代文明最后一位观察者。' '' 'cataclysm:void_core' (ObjK 'cataclysm:the_watcher' '击败虚空潜视') (Ok @()) 'combat' 146

Write-Host "== 追加 · 知识 2（knowledge）=="
New-Quest2 'starciv_k_finale' '编年史 · 终章' '【文明编年史·终章】
从上古之种到终局仪式，你走完了四颗星球。
【回顾】
  绿谷教你如何扎根（农业）
  铁锈教你如何燃烧（工业）
  硅火教你如何思考（信息）
  苍穹教你如何仰望（星际）
【如果还不能结束】终局之前还有：五个首领、精英战队、一切装备图鉴。
【目标】持有 1 颗下界之星——不仅仅是奖励，是新的开始。
【档案馆留言】“读完它的人，就是下一个档案馆。”' '' 'minecraft:nether_star' (Obj 'item_obtain' 'minecraft:nether_star' 1 '持有下界之星') (Ok @()) 'knowledge' 160
New-Quest2 'starciv_k_philosophy' '档案馆 · 四大文明' '【档案馆文献：四种文明的哲学】
  绿谷 · 扎根：种不出粮食的文明，不配仰望星空
  铁锈 · 燃烧：力量需要代价，但代价必须可控
  硅火 · 思考：读懂数据，但别被数据吞噬
  苍穹 · 仰望：文明轮回在苍穹完成，薪火永远传递
【目标】集 4 份【文明精华】向档案馆致敬。
【结语】四种哲学合在一起，才是完整的《星际文明编年史》。' '' 'starciv:civ_essence' (Obj 'item_obtain' 'starciv:civ_essence' 4 '集 4 份文明精华') (Ok @()) 'knowledge' 161

Write-Host ""
$total = (Get-ChildItem $qdir -Filter *.json).Count
Write-Host ("✔ 总共 " + $total + " 个任务")
$bad = 0
Get-ChildItem $qdir -Filter *.json | ForEach-Object { try { Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null } catch { Write-Host ("!! " + $_.Name + " " + $_.Exception.Message); $bad++ } }
Write-Host ("JSON 校验失败: " + $bad)