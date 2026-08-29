# 生成 Questlog 任务书（29 个：主线 11 + 科技 4 + 动物 3 + 建筑 3 + 维度 3 + 知识 5）
# 章节页签：main(主线) / tech(科技) / creatures(动物) / building(建筑) / dimensions(维度) / knowledge(知识)
$ErrorActionPreference = 'Stop'
$qroot = '.\pack\.minecraft\config\questlog'
$qdir = Join-Path $qroot 'quests'
$cdir = Join-Path $qroot 'chapters'
New-Item -ItemType Directory -Force -Path $qdir | Out-Null
New-Item -ItemType Directory -Force -Path $cdir | Out-Null
Get-ChildItem $qdir -Filter *.json | Remove-Item -Force
$enc = New-Object System.Text.UTF8Encoding($false)

function New-Quest([string]$id, [string]$title, [string]$desc, [string]$bg, [string]$icon, [string[]]$pre, [object[]]$objs, [object[]]$rw, [string]$chapter, [int]$sort) {
  $o = [ordered]@{ title = $title; description = $desc; icon = [ordered]@{ item = $icon } }
  if ($bg) { $o['background'] = $bg }
  if ($chapter) { $o['chapter'] = $chapter }
  if ($sort -gt 0) { $o['sort_order'] = $sort }
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
function Write-Chapter([string]$id, [string]$iconItem, [bool]$defaultChapter) {
  $c = [ordered]@{ icon = [ordered]@{ item = $iconItem }; default_chapter = $defaultChapter; hidden = $false }
  [System.IO.File]::WriteAllText((Join-Path (Resolve-Path $cdir).Path ($id + '.json')), ($c | ConvertTo-Json -Depth 4), $enc)
  Write-Host ("  章节 " + $id)
}

# ===== 章节 =====
Write-Chapter 'main' 'minecraft:nether_star' $true
Write-Chapter 'tech' 'minecraft:blast_furnace' $false
Write-Chapter 'creatures' 'minecraft:honeycomb' $false
Write-Chapter 'building' 'minecraft:stone_bricks' $false
Write-Chapter 'dimensions' 'minecraft:ender_pearl' $false
Write-Chapter 'knowledge' 'minecraft:written_book' $false

# ===== 主线 11（main）=====
Write-Host "== 主线 11 =="
New-Quest 'starciv_q01_sprout' '绿谷 · 上古之种' '第一步：在绿谷星安家。$(br)① 寻找平原/河谷的农舍与麦田；$(br)② 前往绿谷中心区域的【星港独石碑】（昼间发光，附近有休眠舱遗迹）；$(br)③ 在独石碑脚下拾取【上古之种】——它是铁锈纪元之前的文明遗物，也是一切晋升的起点。$(br)$(br)提示：种子也可以用锄头开垦时在草地块上发现。' '星港档案馆的记录这样写道：绿谷星是四颗星球中唯一保有远古种子的世界。独石碑下的休眠舱里，上古文明留下了最后的遗产。捡起那颗种子，你就接过了文明的薪火。' 'starciv:ancient_seed' @() (AddAdv @(@{type='questlog:item_obtain'; item='starciv:ancient_seed'; required_amount=1; name='获取上古之种'}) 'starciv:agriculture/start' '绿谷初耕') @(@{type='questlog:item'; item='starciv:civ_essence'; count=2}, @{type='questlog:experience'; experience=20}) 'main' 1
New-Quest 'starciv_q02_stellar_key' '绿谷 · 星门钥匙' '第二步：铸造星门钥匙。$(br)① 准备 1 文明精华（上古之种制成）、4 金锭、4 绿宝石；$(br)② 打开 JEI（E 键列表）搜索【星门钥匙】查看配方；$(br)③ 在工作台合成【星门钥匙】。$(br)$(br)完成后从绿谷星门（独石碑旁）传送到铁锈星废土。' '星门钥匙的作用被发现后，星港档案馆沸腾了——绿谷星门并非传说，而是通往其他三颗星球的唯一通道。铸造钥匙，就是向星空承诺：我们不会困守于此。' 'starciv:stellar_key' @('starciv_q01_sprout') (AddAdv @(@{type='questlog:item_craft'; item='starciv:stellar_key'; required_amount=1; name='铸造星门钥匙'}) 'starciv:agriculture/stellar_key' '星门开启') @(@{type='questlog:experience'; experience=50}) 'main' 2
New-Quest 'starciv_q03_arrive_rust' '铁锈 · 踏上废土' '第三步：踏上铁锈星废土。$(br)① 手持【星门钥匙】走进绿谷星门（独石碑旁的发光方框）；$(br)② 抵达铁锈星——锈红的天空与大地上散布着旧工业遗迹；$(br)③ 开始收集数据残骸，为重启抛光线做准备。$(br)$(br)注意：铁锈星昼夜温差大，请随身带足食物。' '铁锈星曾是旧文明的工业心脏。如今锈蚀的大地仍回荡着机械的呓语——这里的每一块废铁里，都封存着一段被遗忘的科技。' 'minecraft:iron_ingot' @('starciv_q02_stellar_key') (AddAdv @(@{type='questlog:visit_dimension'; dimension='starciv:rustfall'; required_amount=1; name='抵达铁锈星'}) 'starciv:industry/arrival' '铁锈纪元') @(@{type='questlog:item'; item='starciv:data_slivers'; count=4}) 'main' 3
New-Quest 'starciv_q04_biofuel' '铁锈 · 生物燃料' '第四步：合成生物燃料罐。$(br)① 加工【上古之种】获得燃料胚体；$(br)② 备好木炭（烧原木即可）；$(br)③ 按 JEI 配方合成【生物燃料罐】。$(br)$(br)生物燃料是重启铁锈星机器的第一步——它让锈蚀的传动轴重新转动。' '上古之种的基因链解开了谜底——它能在任何环境下发酵。生物燃料罐是重启铁锈星抛光线的最短路径，也是绿谷农业与铁锈工业的第一次握手。' 'starciv:biofuel_canister' @('starciv_q03_arrive_rust') (AddAdv @(@{type='questlog:item_craft'; item='starciv:biofuel_canister'; required_amount=1; name='合成生物燃料罐'}) 'starciv:industry/fuel' '燃料革命') @(@{type='questlog:experience'; experience=80}) 'main' 4
New-Quest 'starciv_q05_slivers' '铁锈 · 数据裂片' '第五步：收集 8 片数据裂片。$(br)① 在铁锈星地下开采【紫水晶矿石】（矿区深处与遗迹中常见）；$(br)② 用研磨装置或精准采集把紫水晶加工成数据裂片；$(br)③ 集齐 8 片后任务完成。$(br)$(br)数据裂片记录了旧文明的生产参数，是解锁硅火科技的关键。' '紫水晶是铁锈星少数未被氧化的晶体。研磨它们得到的数据裂片，记录了旧文明的生产参数——包括如何铸造更精密的零件。' 'starciv:data_slivers' @('starciv_q04_biofuel') (AddAdv @(@{type='questlog:item_obtain'; item='starciv:data_slivers'; required_amount=8; name='收集 8 片数据裂片'}) 'starciv:hidden/lost_tech' '失传科技') @(@{type='questlog:item'; item='starciv:precision_parts'; count=2}) 'main' 5
New-Quest 'starciv_q06_arrive_silicon' '硅火 · 霓虹都市' '第六步：抵达硅火星。$(br)① 从铁锈星星门返回绿谷，再从绿谷星门选择【硅火】坐标；$(br)② 降落在霓虹都市外围；$(br)③ 观察这座城市——自动工厂仍在运转，硅基文明的气息扑面而来。$(br)$(br)提示：硅火都市中心有中央计算机群，是后续任务的主舞台。' '硅火星是最接近旧文明巅峰的世界——整座都市仍亮着霓虹。档案馆的结论：这座城市从未关闭，它在等一个能读懂它的人。' 'minecraft:redstone' @('starciv_q05_slivers') (AddAdv @(@{type='questlog:visit_dimension'; dimension='starciv:silicon'; required_amount=1; name='抵达硅火星'}) 'starciv:information/arrival' '硅基纪元') @(@{type='questlog:experience'; experience=120}) 'main' 6
New-Quest 'starciv_q07_precision' '硅火 · 精密零件' '第七步：锻造 4 个精密零件。$(br)① 用【数据裂片】换成设计图（JEI 查看）；$(br)② 在硅火工业台按配方投入铁锭与红石；$(br)③ 锻造 4 个【精密零件】。$(br)$(br)精密零件是穿梭机的核心部件，也是离开硅火星的先决条件。' '数据裂片终于化成了可用的设计图。精密零件是硅火星工业台的骄傲：只有这里的机床能保证亚毫米公差。' 'starciv:precision_parts' @('starciv_q06_arrive_silicon') (AddAdv @(@{type='questlog:item_craft'; item='starciv:precision_parts'; required_amount=4; name='锻造 4 个精密零件'}) 'starciv:information/chips' '芯片工坊') @(@{type='questlog:experience'; experience=200}) 'main' 7
New-Quest 'starciv_q08_quantum' '硅火 · 量子核心' '第八步：组装量子核心。$(br)① 集齐 2 个精密零件、1 个红石灯、4 块石英（JEI 查配方）；$(br)② 在工作台组装【量子核心】；$(br)③ 前往中央计算机群，核心在那里苏醒。$(br)$(br)核心苏醒后，星门坐标库会展开——通往苍穹的路由此显现。' '量子核心是硅火都市的中枢神经。档案馆的秘档显示：当核心苏醒，星门的坐标库会展开——通往苍穹的路由此显现。' 'starciv:quantum_core' @('starciv_q07_precision') (AddAdv @(@{type='questlog:item_obtain'; item='starciv:quantum_core'; required_amount=1; name='组装量子核心'}) 'starciv:information/core' '量子之心') @(@{type='questlog:item'; item='starciv:warp_core'; count=1}) 'main' 8
New-Quest 'starciv_q09_warp_engine' '硅火 · 跃迁引擎' '第九步：铸造跃迁引擎。$(br)① 备好 1 个量子核心 + 1 个焰火之星 + 4 块紫水晶；$(br)② 按 JEI 配方合成【跃迁引擎】；$(br)③ 它是抵达苍穹星的唯一钥匙——苍穹星不通过星门抵达，它需要跃迁。' '苍穹星不通过星门抵达，它需要跃迁。跃迁引擎由量子核心驱动，是硅火工业与间宇宙物理的结晶。' 'minecraft:firework_rocket' @('starciv_q08_quantum') (AddAdv @(@{type='questlog:item_craft'; item='starciv:warp_engine'; required_amount=1; name='铸造跃迁引擎'}) 'starciv:interstellar/engine' '跃迁引擎') @(@{type='questlog:experience'; experience=350}) 'main' 9
New-Quest 'starciv_q10_arrive_stellaris' '苍穹 · 应许之地' '第十步：穿越苍穹之门。$(br)① 手持【跃迁引擎】回到硅火中心广场的苍穹之门；$(br)② 启动跃迁，抵达苍穹星；$(br)③ 这里悬浮着大陆，生长着发光的晶体森林。$(br)$(br)苍穹星保存着文明的终极答案，但守护者也在等待。' '苍穹星保存着文明的终极答案。传说首批文明在这里完成了“升华”——但他们也留下了守护者。' 'minecraft:nether_star' @('starciv_q09_warp_engine') (AddAdv @(@{type='questlog:visit_dimension'; dimension='starciv:stellaris'; required_amount=1; name='抵达苍穹星'}) 'starciv:interstellar/arrival' '苍穹纪元') @(@{type='questlog:item'; item='starciv:warp_core'; count=2}) 'main' 10
New-Quest 'starciv_q11_final_boss' '苍穹 · 终局仪式' '最终步：击败远古造物【下界合金巨兽】。$(br)① 在苍穹星晶体平原找到巨兽巢穴（大地图上骸骨环绕的区域）；$(br)② 备好整套下界合金装备与充足的药水；$(br)③ 击败 L_Ender 的 Cataclysm 之【下界合金巨兽】。$(br)$(br)仪式完成之时，四颗星球的灯塔将同时亮起——文明的薪火传到了你手中。' '守护者不是敌人，它是第一代文明留下的守门人。击败它并非征服，而是证明：新的文明已具备接过星火的资格。仪式完成之时，四颗星球的灯塔将同时亮起。' 'minecraft:netherite_ingot' @('starciv_q10_arrive_stellaris') (AddAdv @(@{type='questlog:entity_kill'; entity='cataclysm:netherite_monstrosity'; required_amount=1; name='击败下界合金巨兽'}) 'starciv:interstellar/contact' '接触造物') @(@{type='questlog:experience'; experience=1500}, @{type='questlog:item'; item='starciv:warp_core'; count=4}) 'main' 11

# ===== 科技 4（tech）=====
Write-Host "== 科技 4 =="
New-Quest 'starciv_s1_workshop' '科技 · 手作工坊' '科技线第 1 步：建立你的第一座自动化车间。$(br)① 制作 2 个活塞（木板+圆石+铁锭+红石）；$(br)② 积攒 8 个铁锭；$(br)③ 用 Create 的传动轴（铁轴）把第一台机器转起来。$(br)$(br)科技线最终通向硅火的精密制造。' '技师手册上的第一课：工具先于文明。有了车间，你才能把绿谷的粮食变成铁锈的燃料，把铁锈的矿砂变成硅火的电路。' 'minecraft:piston' @('starciv_g_guide') @(@{type='questlog:item_craft'; item='minecraft:piston'; required_amount=2; name='制作 2 个活塞'}, @{type='questlog:item_obtain'; item='minecraft:iron_ingot'; required_amount=8; name='持有 8 个铁锭'}) @(@{type='questlog:experience'; experience=30}) 'tech' 1
New-Quest 'starciv_s2_smeltery' '科技 · 工业熔炉' '科技线第 2 步：铸造高炉，开启大规模冶炼。$(br)① 合成一个【高炉】（5 铁锭 + 熔炉 + 3 平滑石）；$(br)② 储备 16 块煤作为燃料；$(br)③ 用高炉把铁锭产量提上来。$(br)$(br)高炉是铁锈星工业的心脏，也是制造精密零件的前置。' '旧文明把铁锈星变成了钢铁行星，也把天空染成了锈色。档案馆的批注只有一句：重工业可以粗粝，但必须可控。' 'minecraft:blast_furnace' @('starciv_q03_arrive_rust') @(@{type='questlog:item_craft'; item='minecraft:blast_furnace'; required_amount=1; name='铸造高炉'}, @{type='questlog:item_obtain'; item='minecraft:coal'; required_amount=16; name='储备 16 块煤'}) @(@{type='questlog:item'; item='starciv:data_slivers'; count=2}, @{type='questlog:experience'; experience=60}) 'tech' 2
New-Quest 'starciv_s6_axles' '科技 · 动能网络' '科技线第 3 步：铺设动能传动网络。$(br)① 用 Create 制作 8 根【传动轴】（Iron Sheet + 木轴）；$(br)② 连接 1 个【动力源】（水车/风车或手摇机）；$(br)③ 让传动轴把动力送到你的第一台机器。$(br)$(br)动能网络是 Create 自动化一切的骨架。' 'Create 的世界观从一根轴开始：转动、咬合、传递。档案馆把它称作“机械的诗”——文明的脉搏，就藏在这些匀速旋转的零件里。' 'create:shaft' @('starciv_s1_workshop') @(@{type='questlog:item_craft'; item='create:shaft'; required_amount=8; name='制作 8 根传动轴'}, @{type='questlog:item_craft'; item='minecraft:lever'; required_amount=1; name='拉下第一根拉杆'}) @(@{type='questlog:experience'; experience=70}) 'tech' 3
New-Quest 'starciv_s7_pipes' '科技 · 物流管道' '科技线第 4 步：搭建物流管道，让产物自己流动。$(br)① 制作 1 个【物品管道】（Pipez）；$(br)② 把仓库与机器用管道连起来；$(br)③ 观察产物自动转运。$(br)$(br)物流网络建成后，铁锈-绿谷的物资将不再需要人肉搬运。' 'Pipez 把“搬运”从苦力活变成了全自动的诗。档案馆写道：当物资自己流动时，文明才真正腾出手来思考星空。' 'pipez:item_pipe' @('starciv_s6_axles') @(@{type='questlog:item_craft'; item='pipez:item_pipe'; required_amount=1; name='制作物品管道'}) @(@{type='questlog:item'; item='starciv:warp_core'; count=1}, @{type='questlog:experience'; experience=90}) 'tech' 4

# ===== 动物 3（creatures）=====
Write-Host "== 动物 3 =="
New-Quest 'starciv_c1_farm' '动物 · 农场生态' '动物线第 1 步：让农场活起来。$(br)① 圈养至少 2 种动物（牛/羊/猪/鸡均可）；$(br)② 收获 1 瓶蜂蜜（打碎蜂巢或养蜂）；$(br)③ 收集 1 个蛋；$(br)$(br)动物线为农业/酿酒/皮革提供持续产出，是文明的自循环基础。' '博物馆的标本页这样描述绿谷生态：动物不是资源，是同住一颗星球的邻居。善待它们，农场才会回报你。' 'minecraft:egg' @('starciv_q04_biofuel') @(@{type='questlog:item_obtain'; item='minecraft:honey_bottle'; required_amount=1; name='收获 1 瓶蜂蜜'}, @{type='questlog:item_obtain'; item='minecraft:egg'; required_amount=1; name='收集 1 个蛋'}) @(@{type='questlog:experience'; experience=40}) 'creatures' 1
New-Quest 'starciv_c2_pet' '动物 · 驯养伙伴' '动物线第 2 步：驯养你的旅伴。$(br)① 制作 1 根【拴绳】（线+粘液球）；$(br)② 获得 1 个【鞍】（战利品或宝箱）；$(br)③ 驯服一头动物（狼用骨头、猫用鱼、马用空手骑乘）并用拴绳牵着它。$(br)$(br)冒险旅途有个伙伴，夜晚也不会那么孤单。' '旧文明的探险家人手一头坐骑。档案馆的记录：驯养动物不仅是生存手段，更是文明与自然建立信任的第一步。' 'minecraft:lead' @('starciv_c1_farm') @(@{type='questlog:item_craft'; item='minecraft:lead'; required_amount=1; name='制作拴绳'}, @{type='questlog:item_obtain'; item='minecraft:saddle'; required_amount=1; name='获得马鞍'}) @(@{type='questlog:experience'; experience=50}) 'creatures' 2
New-Quest 'starciv_c3_bees' '动物 · 养蜂人' '动物线第 3 步：成为一名养蜂人。$(br)① 制作 1 个【蜂箱】（6 木板 + 3 蜜脾）；$(br)② 在花田边放置蜂箱并等到蜜蜂入住；$(br)③ 收集 2 瓶【蜂蜜瓶】。$(br)$(br)Productive Bees 的基因样本库也是从这一步开始的——未来的变异蜜蜂将有更高产量。' '蜜蜂是生态链的枢纽。Productive Bees 的档案第一页写着：文明的甜，一半来自蜜蜂。' 'minecraft:bee_nest' @('starciv_c2_pet') @(@{type='questlog:item_craft'; item='minecraft:beehive'; required_amount=1; name='制作蜂箱'}, @{type='questlog:item_obtain'; item='minecraft:honey_bottle'; required_amount=2; name='收获 2 瓶蜂蜜'}) @(@{type='questlog:experience'; experience=60}) 'creatures' 3

# ===== 建筑 3（building）=====
Write-Host "== 建筑 3 =="
New-Quest 'starciv_s4_royal_gardens' '建筑 · 文明基建' '建筑线第 1 步：为晨曦花园城堡添砖加瓦。$(br)① 积攒 64 块【石砖】（烧石头后合成）；$(br)② 备齐 16 块【玻璃】；$(br)③ 打开地图（M 键）确认晨曦花园城堡位置（坐标约 60, -250）。$(br)$(br)宏大建筑由砖石砌成，也由文明的心血砌成。' '有人问为什么文明需要城堡与花园。档案馆的回答：因为美本身就是文明的存档。每一座地标，都是给后代的留言。' 'minecraft:stone_bricks' @('starciv_g_agriculture') @(@{type='questlog:item_obtain'; item='minecraft:stone_bricks'; required_amount=64; name='积攒 64 块石砖'}, @{type='questlog:item_obtain'; item='minecraft:glass'; required_amount=16; name='备齐 16 块玻璃'}) @(@{type='questlog:experience'; experience=80}) 'building' 1
New-Quest 'starciv_b2_lighthouse' '建筑 · 灯塔守望' '建筑线第 2 步：为天际灯塔添油点火。$(br)① 制作 4 个【灯笼】（火把+8 铁粒）；$(br)② 制作 8 块【暗黑石】（4 基岩粉? 用黑曜石替代：备 8 块黑曜石）；$(br)③ 前往铁锈星灯塔（约 480, 460）主塔点亮灯火。$(br)$(br)灯塔为夜航的星舰引路，也让远方的人知道：这里还亮着。' '档案馆的航海日志：灯塔不是为了照亮道路，而是为了告诉星空“我们还在”。' 'minecraft:lantern' @('starciv_q03_arrive_rust') @(@{type='questlog:item_craft'; item='minecraft:lantern'; required_amount=4; name='制作 4 个灯笼'}, @{type='questlog:item_obtain'; item='minecraft:obsidian'; required_amount=8; name='备 8 块黑曜石'}) @(@{type='questlog:experience'; experience=70}) 'building' 2
New-Quest 'starciv_s5_silicon_treasures' '建筑 · 霓虹宝物' '建筑线第 3 步：采集硅火星特产，装点你的空中楼阁。$(br)① 采集 16 枚【紫水晶碎片】；$(br)② 收集 16 块【石英】；$(br)③ 把它们带回绿谷，镶嵌在你的建筑上。$(br)$(br)硅火都市的霓虹之下，紫水晶矿脉仍在生长。' '硅火都市的霓虹之下，紫水晶矿脉仍在生长。把它们带回绿谷，让星你界的一端与另一端，共享同一种光芒。' 'minecraft:amethyst_shard' @('starciv_s3_explore') @(@{type='questlog:item_obtain'; item='minecraft:amethyst_shard'; required_amount=16; name='采集 16 枚紫水晶碎片'}, @{type='questlog:item_obtain'; item='minecraft:quartz'; required_amount=16; name='收集 16 块石英'}) @(@{type='questlog:experience'; experience=100}) 'building' 3

# ===== 维度 3（dimensions）=====
Write-Host "== 维度 3 =="
New-Quest 'starciv_s3_explore' '维度 · 星际远行' '维度线第 1 步：亲访三颗星球。$(br)① 从各星门分别传送至【铁锈星】【硅火星】【苍穹星】各一次；$(br)② 在每颗星球至少停留 1 分钟；$(br)③ 返回绿谷并完成任务。$(br)$(br)三颗星球的景象与特产，是主线之外不可错过的风景。' '四星文明从不是孤岛。档案馆给每位新晋升者的建议：走出去，亲眼看一看锈蚀的大地和霓虹的都市，然后你才会真正理解要守护的是什么。' 'minecraft:compass' @('starciv_q05_slivers') @(@{type='questlog:visit_dimension'; dimension='starciv:rustfall'; required_amount=1; name='再访铁锈星'}, @{type='questlog:visit_dimension'; dimension='starciv:silicon'; required_amount=1; name='探访硅火星'}, @{type='questlog:visit_dimension'; dimension='starciv:stellaris'; required_amount=1; name='遨游苍穹星'}) @(@{type='questlog:experience'; experience=150}, @{type='questlog:item'; item='starciv:warp_core'; count=1}) 'dimensions' 1
New-Quest 'starciv_d2_rust_tour' '维度 · 铁锈巡礼' '维度线第 2 步：深入铁锈星工业遗迹。$(br)① 重访铁锈星，探索至少一处大型工厂遗迹；$(br)② 收集 16 份【红石粉】（遗迹宝箱与矿脉中常见）；$(br)③ 记住你看到的高炉群——那是旧文明燃烧过的证明。$(br)$(br)地标：铁锈灯塔（约 -480, 460 一带）。' '巡礼的意义在于记住：机械的辉煌与代价从来一体两面。档案馆希望每一位晋升者都亲眼见过，再决定自己要成为怎样的文明。' 'minecraft:redstone' @('starciv_s3_explore') @(@{type='questlog:item_obtain'; item='minecraft:redstone'; required_amount=16; name='收集 16 份红石粉'}, @{type='questlog:visit_dimension'; dimension='starciv:rustfall'; required_amount=1; name='重游铁锈星'}) @(@{type='questlog:experience'; experience=90}) 'dimensions' 2
New-Quest 'starciv_d3_stellar_crystals' '维度 · 苍穹水晶' '维度线第 3 步：遨游苍穹星的晶体森林。$(br)① 再次抵达苍穹星；$(br)② 在晶体森林采集 8 枚【紫水晶碎片】（发光的晶簇）；$(br)③ 登上一座悬浮岛远眺大陆全貌。$(br)$(br)苍穹星是最接近星空的地方——把这片光芒带回你的世界。' '苍穹星的晶体森林记录着星光的形状。档案馆的诗句：每摘下一枚水晶，就收藏了一束星光。' 'minecraft:amethyst_block' @('starciv_s3_explore') @(@{type='questlog:visit_dimension'; dimension='starciv:stellaris'; required_amount=1; name='遨游苍穹星'}, @{type='questlog:item_obtain'; item='minecraft:amethyst_shard'; required_amount=8; name='采集 8 枚紫水晶碎片'}) @(@{type='questlog:experience'; experience=110}) 'dimensions' 3

# ===== 知识 5（knowledge）=====
Write-Host "== 知识 5 =="
New-Quest 'starciv_g_guide' '指引 · 成为文明' '手册《星际文明编年史·探索手册》的内容已并入任务书。$(br)① 阅读本章了解开局：四季节奏、性能建议、阶段规则；$(br)② 每阶段必须按顺序推进，否则星门不会响应；$(br)③ 参考手册可随时在物品栏打开。$(br)$(br)核心规则：绿谷(农业)→铁锈(工业)→硅火(信息)→苍穹(星际)，阶段不可跳越。' '星港档案馆把四星文明的哲学写进了每一页。成为文明的第一步不是征服，而是理解——理解四季、理解机械、理解数据，最后理解星空。' 'minecraft:written_book' @('starciv_q01_sprout') @(@{type='questlog:item_obtain'; item='minecraft:book'; required_amount=1; name='拥有任意书籍'}) @(@{type='questlog:experience'; experience=10}) 'knowledge' 1
New-Quest 'starciv_g_agriculture' '指引 · 绿谷农业' '农业册并入任务书。$(br)① 四季系统决定耕种节奏：春播种、夏护养、秋丰收、冬温室（Botany Pots）；$(br)② 养蜂（Productive Bees）产基因样本；$(br)③ 酿酒（Brewin and Chewin）建立村落经济；$(br)④ 村民交易（Easy Villagers）织成贸易网络。$(br)$(br)农业是唯一能自我循环的起点——先吃饱，再远征。' '绿谷星的农田不是背景，而是文明的温床。档案馆始终相信：能种出粮食的文明，才配仰望星空。' 'minecraft:wheat' @('starciv_q02_stellar_key') @(@{type='questlog:item_craft'; item='minecraft:wheat'; required_amount=16; name='收获 16 个小麦'}) @(@{type='questlog:experience'; experience=25}) 'knowledge' 2
New-Quest 'starciv_g_industry' '指引 · 铁锈工业' '工业册并入任务书。$(br)① Create 传动轴与皮带构建机械城；$(br)② Immersive Engineering 高压电网覆盖废土；$(br)③ 注意污染值——工业必须与自然和解；$(br)④ 铁锈星任务核心是产出与减排的平衡。$(br)$(br)参考：科技线 4 个任务与本页配套食用。' '铁锈星教会文明一件事：力量需要代价。但档案馆记录显示，旧文明正是败于对代价的傲慢。这一次，让机械服务于田园。' 'minecraft:piston' @('starciv_q04_biofuel') @(@{type='questlog:item_craft'; item='minecraft:piston'; required_amount=2; name='制作 2 个活塞'}) @(@{type='questlog:experience'; experience=30}) 'knowledge' 3
New-Quest 'starciv_g_information' '指引 · 硅火信息' '信息册并入任务书。$(br)① Refined Storage 存储网络统御万物；$(br)② Integrated Dynamics 以逻辑编程收发数据；$(br)③ CC:Tweaked 的电脑让整座都市自动化；$(br)④ AE2 的能量走廊是终局电网。$(br)$(br)硅火星的答案藏在比特与晶片之间——主线第 6~9 步就是实践课。' '硅火文明几乎抵达了“上传”的境界——他们把自己写进了数据。档案馆警告：信息是有生命的，读懂它，但别被它吞噬。' 'minecraft:redstone_lamp' @('starciv_q07_precision') @(@{type='questlog:item_craft'; item='minecraft:redstone_lamp'; required_amount=1; name='制作红石灯'}) @(@{type='questlog:experience'; experience=40}) 'knowledge' 4
New-Quest 'starciv_g_interstellar' '指引 · 苍穹星际' '星际册并入任务书。$(br)① Ad Astra 火箭与空间站搭建跨星球航线；$(br)② 跃迁引擎（warp engine）是通往苍穹的唯一载体；$(br)③ L_Ender 的 Cataclysm 的 Boss 是终局试炼；$(br)④ 集齐四星科技的文明，才有资格举行终局仪式。$(br)$(br)最终奖励：四星灯塔同亮，文明薪火相传。' '苍穹星不是终点，而是起点。档案馆的最后一页写着：文明的轮回在苍穹完成，而薪火将永远传递。' 'minecraft:elytra' @('starciv_q10_arrive_stellaris') @(@{type='questlog:item_obtain'; item='starciv:warp_core'; required_amount=1; name='持有跃迁核心'}) @(@{type='questlog:experience'; experience=50}) 'knowledge' 5

Write-Host ""
$n = (Get-ChildItem $qdir -Filter *.json).Count
$nc = (Get-ChildItem $cdir -Filter *.json).Count
Write-Host ("✔ 共生成 " + $n + " 个任务 / " + $nc + " 个章节")
$bad = 0
Get-ChildItem $qdir -Filter *.json | ForEach-Object { try { Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null } catch { Write-Host ("!! " + $_.Name + " " + $_.Exception.Message); $bad++ } }
Write-Host ("JSON 校验失败: " + $bad)