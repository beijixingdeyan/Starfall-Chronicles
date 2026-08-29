# 生成 Questlog 任务书 v3（46 个任务 / 7 章节）
# 设计原则：
#  - 全部任务不设前置（Questlog 列表只显示已触发任务；去前置 = 开局全可见，顺序由章节+排序+描述引导）
#  - 描述用真实换行（Questlog 不识别 $(br)，之前 v2 的 $(br) 会原样显示）
#  - 每任务图文式分段：去哪 / 干什么 / 注意事项 / 剧情背景
$ErrorActionPreference = 'Stop'
$qroot = '.\pack\.minecraft\config\questlog'
$qdir = Join-Path $qroot 'quests'
$cdir = Join-Path $qroot 'chapters'
New-Item -ItemType Directory -Force -Path $qdir | Out-Null
New-Item -ItemType Directory -Force -Path $cdir | Out-Null
Get-ChildItem $qdir -Filter *.json | Remove-Item -Force
$enc = New-Object System.Text.UTF8Encoding($false)

function New-Quest([string]$id, [string]$title, [string]$desc, [string]$bg, [string]$icon, [object[]]$objs, [object[]]$rw, [string]$chapter, [int]$sort) {
  $o = [ordered]@{ title = $title; description = $desc; icon = [ordered]@{ item = $icon } }
  if ($bg) { $o['background'] = $bg }
  if ($chapter) { $o['chapter'] = $chapter }
  if ($sort -gt 0) { $o['sort_order'] = $sort }
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

# ===== 章节 7 =====
Write-Chapter 'main' 'minecraft:nether_star' $true
Write-Chapter 'tech' 'minecraft:blast_furnace' $false
Write-Chapter 'creatures' 'minecraft:honeycomb' $false
Write-Chapter 'building' 'minecraft:stone_bricks' $false
Write-Chapter 'dimensions' 'minecraft:ender_pearl' $false
Write-Chapter 'combat' 'minecraft:netherite_sword' $false
Write-Chapter 'knowledge' 'minecraft:written_book' $false

# ===== 主线 11（main）全部可先看，靠物品门槛与描述引导顺序 =====
Write-Host "== 主线 11 =="
New-Quest 'starciv_q01_sprout' '① 绿谷 · 上古之种' '这是你文明的起点，也是全流程的“开门”任务。
【去哪里】绿谷星（出生世界）中心区域，寻找发光的【星港独石碑】，独石碑脚下与周边遗迹里有上古文明的休眠舱。
【干什么】拾取【上古之种】；也可以开垦草地块碰碰运气。
【为什么】上古之种是这一切的钥匙：农业、燃料、星门科技都以它为基础。
【注意】种子很珍贵，先种进土里等它成熟，你还会用到它做【文明精华】。' '星港档案馆的记录这样写道：绿谷星是四颗星球中唯一保有远古种子的世界。独石碑下的休眠舱里，上古文明留下了最后的遗产。捡起那颗种子，你就接过了文明的薪火。' 'starciv:ancient_seed' (AddAdv @(@{type='questlog:item_obtain'; item='starciv:ancient_seed'; required_amount=1; name='获取上古之种'}) 'starciv:agriculture/start' '绿谷初耕') @(@{type='questlog:item'; item='starciv:civ_essence'; count=2}, @{type='questlog:experience'; experience=20}) 'main' 1
New-Quest 'starciv_q02_stellar_key' '② 绿谷 · 星门钥匙' '主线第二步（建议先完成①）。
【材料】1 文明精华（上古之种制成）、4 金锭、4 绿宝石。
【怎么做】打开 JEI（按 E 键后右侧配方列表，搜索“星门钥匙”）查看配方，在工作台合成。
【为什么】星门钥匙是激活星门、前往铁锈星的凭证——没有它，你哪儿也去不了。
【提示】配方详情见 JEI；材料不够就多挖矿。' '星门钥匙的作用被发现后，星港档案馆沸腾了——绿谷星门并非传说，而是通往其他三颗星球的唯一通道。铸造钥匙，就是向星空承诺：我们不会困守于此。' 'starciv:stellar_key' (AddAdv @(@{type='questlog:item_craft'; item='starciv:stellar_key'; required_amount=1; name='铸造星门钥匙'}) 'starciv:agriculture/stellar_key' '星门开启') @(@{type='questlog:experience'; experience=50}) 'main' 2
New-Quest 'starciv_q03_arrive_rust' '③ 铁锈 · 踏上废土' '主线第三步（需持有星门钥匙）。
【去哪里】回到绿谷星门（独石碑旁的发光方框），手持【星门钥匙】走进去，传送到铁锈星。
【铁锈星是什么】旧文明的工业心脏：锈红色的天与地、废弃工厂、高炉群、深埋的紫水晶矿。
【干什么】落地后探索废墟，收集初期物资，为重启抛光线做准备。
【注意】铁锈星昼夜温差大，带足食物；夜里警惕游荡的亡灵。' '铁锈星曾是旧文明的工业心脏。如今锈蚀的大地仍回荡着机械的呓语——这里的每一块废铁里，都封存着一段被遗忘的科技。' 'minecraft:iron_ingot' (AddAdv @(@{type='questlog:visit_dimension'; dimension='starciv:rustfall'; required_amount=1; name='抵达铁锈星'}) 'starciv:industry/arrival' '铁锈纪元') @(@{type='questlog:item'; item='starciv:data_slivers'; count=4}) 'main' 3
New-Quest 'starciv_q04_biofuel' '④ 铁锈 · 生物燃料' '主线第四步。
【材料】上古之种（或它的胚体）+ 木炭（烧原木）。
【怎么做】按 JEI 配方合成【生物燃料罐】。
【为什么】生物燃料是重启铁锈星机器的燃料——它们让锈蚀的传动轴重新转动，也解锁后续工厂科技。
【提示】这步是农业与工业的第一次握手，之后绿谷粮食→铁锈燃料的循环就建立了。' '上古之种的基因链解开了谜底——它能在任何环境下发酵。生物燃料罐是重启铁锈星抛光线的最短路径，也是绿谷农业与铁锈工业的第一次握手。' 'starciv:biofuel_canister' (AddAdv @(@{type='questlog:item_craft'; item='starciv:biofuel_canister'; required_amount=1; name='合成生物燃料罐'}) 'starciv:industry/fuel' '燃料革命') @(@{type='questlog:experience'; experience=80}) 'main' 4
New-Quest 'starciv_q05_slivers' '⑤ 铁锈 · 数据裂片' '主线第五步。
【去哪里】铁锈星地下：紫水晶矿石在矿洞深处与遗迹中常见。
【干什么】开采紫水晶，用研磨装置或精准采集加工成【数据裂片】，集齐 8 片。
【为什么】裂片记录了旧文明的生产参数，是后续精密零件的图纸来源。
【提示】挖矿带好火把与镐；深矿层注意岩浆与怪物。' '紫水晶是铁锈星少数未被氧化的晶体。研磨它们得到的数据裂片，记录了旧文明的生产参数——包括如何铸造更精密的零件。' 'starciv:data_slivers' (AddAdv @(@{type='questlog:item_obtain'; item='starciv:data_slivers'; required_amount=8; name='收集 8 片数据裂片'}) 'starciv:hidden/lost_tech' '失传科技') @(@{type='questlog:item'; item='starciv:precision_parts'; count=2}) 'main' 5
New-Quest 'starciv_q06_arrive_silicon' '⑥ 硅火 · 霓虹都市' '主线第六步（建议先完成⑤）。
【去哪里】从铁锈星星门返回绿谷，再从绿谷星门选择【硅火】坐标。
【硅火星是什么】最接近旧文明巅峰的世界：整座都市仍亮着霓虹，中央有庞大的计算机群。
【干什么】降落在都市外围，熟悉环境，寻找工业台。
【注意】都市里有自动防御设施，别在夜里乱闯。' '硅火星是最接近旧文明巅峰的世界——整座都市仍亮着霓虹。档案馆的结论：这座城市从未关闭，它在等一个能读懂它的人。' 'minecraft:redstone' (AddAdv @(@{type='questlog:visit_dimension'; dimension='starciv:silicon'; required_amount=1; name='抵达硅火星'}) 'starciv:information/arrival' '硅基纪元') @(@{type='questlog:experience'; experience=120}) 'main' 6
New-Quest 'starciv_q07_precision' '⑦ 硅火 · 精密零件' '主线第七步。
【材料】数据裂片 + 铁锭 + 红石（具体配方见 JEI 的【精密零件】）。
【怎么做】在硅火工业台锻造 4 个【精密零件】。
【为什么】精密零件是穿梭机的核心部件，也是离开硅火星、组装量子核心的条件。
【提示】硅火星的机床精度是四星最高的，别在别处瞎试。' '数据裂片终于化成了可用的设计图。精密零件是硅火星工业台的骄傲：只有这里的机床能保证亚毫米公差。' 'starciv:precision_parts' (AddAdv @(@{type='questlog:item_craft'; item='starciv:precision_parts'; required_amount=4; name='锻造 4 个精密零件'}) 'starciv:information/chips' '芯片工坊') @(@{type='questlog:experience'; experience=200}) 'main' 7
New-Quest 'starciv_q08_quantum' '⑧ 硅火 · 量子核心' '主线第八步。
【材料】2 个精密零件 + 1 个红石灯 + 4 块石英（JEI 查看）。
【怎么做】在工作台组装【量子核心】。
【干什么】带着核心前往中央计算机群——核心会在那里苏醒，星门坐标库将展开，通往苍穹的路由此显现。
【提示】核心苏醒时会引发短暂的断电故障，提前保存进度。' '量子核心是硅火都市的中枢神经。档案馆的秘档显示：当核心苏醒，星门的坐标库会展开——通往苍穹的路由此显现。' 'starciv:quantum_core' (AddAdv @(@{type='questlog:item_obtain'; item='starciv:quantum_core'; required_amount=1; name='组装量子核心'}) 'starciv:information/core' '量子之心') @(@{type='questlog:item'; item='starciv:warp_core'; count=1}) 'main' 8
New-Quest 'starciv_q09_warp_engine' '⑨ 硅火 · 跃迁引擎' '主线第九步。
【材料】1 个量子核心 + 1 个焰火之星 + 4 块紫水晶（JEI 查看）。
【怎么做】按配方合成【跃迁引擎】。
【为什么】苍穹星不通过星门抵达，它需要跃迁——跃迁引擎是唯一载体。
【提示】跃迁引擎会留在你手里，放心使用。' '苍穹星不通过星门抵达，它需要跃迁。跃迁引擎由量子核心驱动，是硅火工业与间宇宙物理的结晶。' 'minecraft:firework_rocket' (AddAdv @(@{type='questlog:item_craft'; item='starciv:warp_engine'; required_amount=1; name='铸造跃迁引擎'}) 'starciv:interstellar/engine' '跃迁引擎') @(@{type='questlog:experience'; experience=350}) 'main' 9
New-Quest 'starciv_q10_arrive_stellaris' '⑩ 苍穹 · 应许之地' '主线第十步（需持有跃迁引擎）。
【去哪里】回到硅火中心广场的【苍穹之门】，手持跃迁引擎启动跃迁。
【苍穹星是什么】悬浮大陆与发光晶体森林，保存着文明的终极答案——但守护者也在等待。
【干什么】落地后熟悉环境，寻找晶体平原上的巨兽巢穴。
【注意】苍穹星的生物比前三个世界强，先做好装备再来。' '苍穹星保存着文明的终极答案。传说首批文明在这里完成了“升华”——但他们也留下了守护者。' 'minecraft:nether_star' (AddAdv @(@{type='questlog:visit_dimension'; dimension='starciv:stellaris'; required_amount=1; name='抵达苍穹星'}) 'starciv:interstellar/arrival' '苍穹纪元') @(@{type='questlog:item'; item='starciv:warp_core'; count=2}) 'main' 10
New-Quest 'starciv_q11_final_boss' '⑪ 苍穹 · 终局仪式' '最终步：击败远古造物【下界合金巨兽】。
【去哪里】苍穹星晶体平原，骸骨环绕的巨兽巢穴。
【准备】整套下界合金装备、充足药水与食物；参考【战斗】页签了解它的弱点。
【怎么做】正面迎战 L_Ender 的 Cataclysm 之【下界合金巨兽】。它攻击高、范围大，注意走位与血量管理。
【为什么】守护者是第一代文明留下的守门人。击败它并非征服，而是证明：新的文明已具备接过星火的资格。
【结尾】仪式完成时，四颗星球的灯塔将同时亮起——文明的薪火传到了你手中。' '守护者不是敌人，它是第一代文明留下的守门人。击败它并非征服，而是证明：新的文明已具备接过星火的资格。仪式完成之时，四颗星球的灯塔将同时亮起。' 'minecraft:netherite_ingot' (AddAdv @(@{type='questlog:entity_kill'; entity='cataclysm:netherite_monstrosity'; required_amount=1; name='击败下界合金巨兽'}) 'starciv:interstellar/contact' '接触造物') @(@{type='questlog:experience'; experience=1500}, @{type='questlog:item'; item='starciv:warp_core'; count=4}) 'main' 11

# ===== 科技 6（tech）=====
Write-Host "== 科技 6 =="
New-Quest 'starciv_s1_workshop' '手作工坊（自动化入门）' '科技线之一：建立你的第一座车间。
【材料】2 个活塞（木板+圆石+铁锭+红石）+ 8 个铁锭。
【干什么】造出活塞后，用 Create 的【传动轴】（见科技线 x_tech_create）把第一台机器转起来。
【指引】这条线最终通向硅火的精密制造；主线⑤⑥⑦会用到这里的知识。
【背景】技师手册第一课：工具先于文明。' '技师手册上的第一课：工具先于文明。有了车间，你才能把绿谷的粮食变成铁锈的燃料，把铁锈的矿砂变成硅火的电路。' 'minecraft:piston' @(@{type='questlog:item_craft'; item='minecraft:piston'; required_amount=2; name='制作 2 个活塞'}, @{type='questlog:item_obtain'; item='minecraft:iron_ingot'; required_amount=8; name='持有 8 个铁锭'}) @(@{type='questlog:experience'; experience=30}) 'tech' 20
New-Quest 'starciv_s2_smeltery' '工业熔炉（规模冶炼）' '科技线之二：铸造高炉。
【材料】高炉（5 铁锭 + 熔炉 + 3 平滑石）+ 16 块煤。
【为什么】高炉是铁锈星工业的心脏：冶炼速度翻倍，是生产精密零件的必须配套。
【指引】建议在抵达铁锈星后完成；随后去【维度】页签认识铁锈星全貌。
【背景】重工业可以粗粝，但必须可控。' '旧文明把铁锈星变成了钢铁行星，也把天空染成了锈色。档案馆的批注只有一句：重工业可以粗粝，但必须可控。' 'minecraft:blast_furnace' @(@{type='questlog:item_craft'; item='minecraft:blast_furnace'; required_amount=1; name='铸造高炉'}, @{type='questlog:item_obtain'; item='minecraft:coal'; required_amount=16; name='储备 16 块煤'}) @(@{type='questlog:item'; item='starciv:data_slivers'; count=2}, @{type='questlog:experience'; experience=60}) 'tech' 21
New-Quest 'starciv_s6_axles' '动能网络（Create 骨架）' '科技线之三：铺设传动。
【材料】8 根【传动轴】（Create：木轴+铁片，JEI 查看）+ 1 个拉杆。
【干什么】把传动轴连接动力源（水车/风车/手摇机），让动力传到机器。
【为什么】动能网络是 Create 自动化一切的骨架——传送带、钻头、机械臂都靠它。
【提示】对着传动轴右键可以调整朝向，Shift+右键拆除。' 'Create 的世界观从一根轴开始：转动、咬合、传递。档案馆把它称作“机械的诗”——文明的脉搏，就藏在这些匀速旋转的零件里。' 'create:shaft' @(@{type='questlog:item_craft'; item='create:shaft'; required_amount=8; name='制作 8 根传动轴'}, @{type='questlog:item_craft'; item='minecraft:lever'; required_amount=1; name='拉下第一根拉杆'}) @(@{type='questlog:experience'; experience=70}) 'tech' 22
New-Quest 'starciv_s7_pipes' '物流管道（自动转运）' '科技线之四：让物资自己流动。
【材料】1 个【物品管道】（Pipez，JEI 查看配方）。
【干什么】把仓库与机器用管道连起来（管道可左键切换提取/输入模式）。
【为什么】物流网络建成后，铁锈-绿谷的物资不再需要人肉搬运。
【提示】Pipez 管道支持升级件，后期可提速至无限。' 'Pipez 把“搬运”从苦力活变成了全自动的诗。档案馆写道：当物资自己流动时，文明才真正腾出手来思考星空。' 'pipez:item_pipe' @(@{type='questlog:item_craft'; item='pipez:item_pipe'; required_amount=1; name='制作物品管道'}) @(@{type='questlog:item'; item='starciv:warp_core'; count=1}, @{type='questlog:experience'; experience=90}) 'tech' 23
New-Quest 'starciv_x_tech_create' '百科 · Create 入门' '【创造（Create）】本包的中期机械核心。
【是什么】用传动轴+齿轮+皮带搭出“齿轮机械城市”：
  · 动力源：水车、风车、蒸汽机
  · 传动：传动轴（铁）、齿轮箱（变速）
  · 工作机：鼓风机、碾磨机、钻头、机械臂、传送带
【怎么上手】先做 1 个【齿轮】（create:cogwheel），再连一根轴带动它；看着它转起来，你就入门了。
【推荐】机械动力官方演示（游戏内/网上均有）。
【本包配套】工业熔炉、动能网络、物流管道都是它的应用。' '机械不是目的，是手段。档案馆写道：Create 的每一根轴都在复述同一个故事——文明用转动对抗熵增。' 'create:cogwheel' @(@{type='questlog:item_craft'; item='create:cogwheel'; required_amount=1; name='制作第一个齿轮'}) @(@{type='questlog:experience'; experience=40}) 'tech' 24
New-Quest 'starciv_x_tech_ie' '百科 · 沉浸工程' '【沉浸工程（Immersive Engineering）】高压电网与重工。
【是什么】多块结构（Multi-block）的工业模组：高炉、电弧炉、高压线塔、炼油厂。
【怎么上手】
  · 造【工程师锤】锻打多块结构
  · 搭高压电网：发电机→变压器→线塔→机器
  · 电弧炉一次熔炼 3 矿物
【本包定位】铁锈星的电网基建，与 Create 并行不悖：传动管机械，电网管冶金。
【提示】高压线有电，别裸手碰（会掉血）。' '旧文明的高压线塔至今矗立在废土上。档案馆的批注：电是文明的骨骼，而电网是它的脊梁。' 'immersiveengineering:coil_lv' @(@{type='questlog:item_craft'; item='immersiveengineering:coil_lv'; required_amount=1; name='制作低压线圈'}) @(@{type='questlog:experience'; experience=50}) 'tech' 25

# ===== 动物 6（creatures）=====
Write-Host "== 动物 6 =="
New-Quest 'starciv_c1_farm' '动物 · 农场生态' '动物线之一：让农场活起来。
【干什么】① 圈养至少 2 种动物（牛/羊/猪/鸡）；② 收获 1 瓶蜂蜜（打碎野生蜂巢或用玻璃瓶装蜜）；③ 收集 1 个蛋。
【为什么】动物是皮革、食物、酿酒的来源，也是自循环农业的基础。
【提示】用小麦引诱牛/羊进圈，栅栏+栅栏门围好。' '动物不是资源，是同住一颗星球的邻居。善待它们，农场才会回报你。' 'minecraft:egg' @(@{type='questlog:item_obtain'; item='minecraft:honey_bottle'; required_amount=1; name='收获 1 瓶蜂蜜'}, @{type='questlog:item_obtain'; item='minecraft:egg'; required_amount=1; name='收集 1 个蛋'}) @(@{type='questlog:experience'; experience=40}) 'creatures' 30
New-Quest 'starciv_c2_pet' '动物 · 驯养伙伴' '动物线之二：驯养你的旅伴。
【材料】1 根【拴绳】（线+粘液球）+ 1 个【鞍】（地牢/遗迹宝箱或钓鱼）。
【干什么】驯服一头动物：狼用骨头、猫用鱼、马空手骑乘到冒爱心；驯服后用拴绳牵着它逛世界。
【提示】马可以装备鞍与马铠，是前期最好的陆地交通工具。' '旧文明的探险家人手一头坐骑。驯养动物不仅是生存手段，更是文明与自然建立信任的第一步。' 'minecraft:lead' @(@{type='questlog:item_craft'; item='minecraft:lead'; required_amount=1; name='制作拴绳'}, @{type='questlog:item_obtain'; item='minecraft:saddle'; required_amount=1; name='获得马鞍'}) @(@{type='questlog:experience'; experience=50}) 'creatures' 31
New-Quest 'starciv_c3_bees' '动物 · 养蜂人' '动物线之三：养蜂与基因样本。
【材料】1 个【蜂箱】（6 木板+3 蜜脾）+ 2 瓶【蜂蜜瓶】。
【干什么】把蜂箱放在花田边，等蜜蜂入住；用玻璃瓶收蜜。
【为什么】Productive Bees 的基因样本库从这一步开始——未来可杂交出高产量变异蜂。
【注意】蜜蜂会蜇人！用蜂蜜瓶右键蜂巢会更安全。' '蜜蜂是生态链的枢纽。Productive Bees 的档案第一页写着：文明的甜，一半来自蜜蜂。' 'minecraft:bee_nest' @(@{type='questlog:item_craft'; item='minecraft:beehive'; required_amount=1; name='制作蜂箱'}, @{type='questlog:item_obtain'; item='minecraft:honey_bottle'; required_amount=2; name='收获 2 瓶蜂蜜'}) @(@{type='questlog:experience'; experience=60}) 'creatures' 32
New-Quest 'starciv_x_mob_beasts' '图鉴 · 荒野巨兽' '【Alex 的猛兽（Alex 的动物）】荒野生物图鉴（部分）：
  · 驼鹿 Moose：针叶林，掉落鹿皮，可做装备
  · 箭猪 Porcupine：森林，被攻击会反击
  · 秃鹫 Vulture：荒野，食腐，会聚集在尸体旁
  · 鳄鱼 Crocodile：沼泽/河流，水里很快
  · 金丝雀 Canary：矿洞，报警提示危险
【任务】收集 4 张【皮革】合成皮革套装，象征你开始在这片土地立足。
【提示】远距离用弓箭，近战看走位；大型掠食者前期避开。' '荒野不欢迎懦夫，但也不拒绝谨慎者。档案馆的猎人手记：观察它们的习性，比盲目战斗更有效。' 'minecraft:leather' @(@{type='questlog:item_obtain'; item='minecraft:leather'; required_amount=4; name='收集 4 张皮革'}) @(@{type='questlog:experience'; experience=45}) 'creatures' 33
New-Quest 'starciv_x_mob_friends' '图鉴 · 友邻生灵' '【自然友好生物】它们不攻击你，且各有用途：
  · 火蜥蜴（Naturalist）：温暖水域，可驯养为伙伴
  · 蝴蝶/小鹿（Naturalist）：点缀生态
  · 萤火虫（自然生成）：夜晚的微光
  · 兔/羊驼/狐狸：常规友好生物，可繁殖
【任务】用胡萝卜繁殖 2 只兔子（或任意友好生物）。
【提示】友好生物是生态链的信号：它们在，说明这片土地还健康。' '博物馆的标本页写道：生态的繁荣是最可靠的繁荣。' 'minecraft:carrot' @(@{type='questlog:item_obtain'; item='minecraft:carrot'; required_amount=4; name='种下 4 根胡萝卜'}) @(@{type='questlog:experience'; experience=35}) 'creatures' 34
New-Quest 'starciv_x_mob_bees' '图鉴 · 织蜂与杂交' '【产物蜜蜂（Productive Bees）】养蜂进阶。
【是什么】可以培育数百种蜜蜂，每种产出独特资源（蜜、蜡、甚至铁/红石）。
【怎么玩】
  · 基础：野生蜂巢→捕捉蜂后→放入蜂箱繁殖
  · 进阶：用【基因样本】改造蜂种，提高产量/速度
  · 自动化：蜂箱+管道，全自动收蜜
【任务】构建 2 个蜂箱的自动收蜜线（收集 3 瓶蜂蜜瓶）。
【提示】不同生物群系有不同蜂种，四颗星球的蜂蜜风味也不同。' '当蜜蜂学会自动化，文明就学会了谦逊——把最细小的协作交给大自然，自己也得到最甜美的回报。' 'minecraft:honeycomb' @(@{type='questlog:item_obtain'; item='minecraft:honey_bottle'; required_amount=3; name='收集 3 瓶蜂蜜瓶'}) @(@{type='questlog:experience'; experience=70}) 'creatures' 35

# ===== 建筑 7（building）=====
Write-Host "== 建筑 7 =="
New-Quest 'starciv_s4_royal_gardens' '建筑 · 文明基建' '建筑线之一：为晨曦花园城堡添砖加瓦。
【材料】64 块【石砖】（烧石头→合成）+ 16 块【玻璃】。
【去哪里】晨曦花园城堡：绿谷坐标约 (60, 79, -250)——从绿谷中心朝东南走。
【为什么】地标不只是一栋楼，它是文明的存档：城堡、灯塔、霓虹亭、飞艇。
【完成后】去【建筑·城堡】任务看它的全貌与拍摄点。' '有人问为什么文明需要城堡与花园。档案馆的回答：因为美本身就是文明的存档。每一座地标，都是给后代的留言。' 'minecraft:stone_bricks' @(@{type='questlog:item_obtain'; item='minecraft:stone_bricks'; required_amount=64; name='积攒 64 块石砖'}, @{type='questlog:item_obtain'; item='minecraft:glass'; required_amount=16; name='备齐 16 块玻璃'}) @(@{type='questlog:experience'; experience=80}) 'building' 40
New-Quest 'starciv_b2_lighthouse' '建筑 · 灯塔守望' '建筑线之二：为铁锈灯塔添油点火。
【材料】4 个【灯笼】（火把+8 铁粒）+ 8 块【黑曜石】。
【去哪里】铁锈星灯塔，坐标约 (480, 76, 460)——锈色平原上的高塔。
【为什么】灯塔为夜航的星舰引路，也让远方的人知道：这里还亮着。
【提示】这里是铁锈星拍风景照的最佳机位之一。' '档案馆的航海日志：灯塔不是为了照亮道路，而是为了告诉星空“我们还在”。' 'minecraft:lantern' @(@{type='questlog:item_craft'; item='minecraft:lantern'; required_amount=4; name='制作 4 个灯笼'}, @{type='questlog:item_obtain'; item='minecraft:obsidian'; required_amount=8; name='备 8 块黑曜石'}) @(@{type='questlog:experience'; experience=70}) 'building' 41
New-Quest 'starciv_s5_silicon_treasures' '建筑 · 霓虹宝物' '建筑线之三：采集硅火特产装点建筑。
【材料】16 枚【紫水晶碎片】+ 16 块【石英】。
【去哪里】硅火星（紫水晶矿脉在都市外围岩层）。
【为什么】把硅火的光芒带回绿谷——让星际的两端共享同一种光。
【提示】紫水晶碎片也可用于合成数据裂片（主线⑤），规划好用量。' '硅火都市的霓虹之下，紫水晶矿脉仍在生长。把它们带回绿谷，让星际的一端与另一端，共享同一种光芒。' 'minecraft:amethyst_shard' @(@{type='questlog:item_obtain'; item='minecraft:amethyst_shard'; required_amount=16; name='采集 16 枚紫水晶碎片'}, @{type='questlog:item_obtain'; item='minecraft:quartz'; required_amount=16; name='收集 16 块石英'}) @(@{type='questlog:experience'; experience=100}) 'building' 42
New-Quest 'starciv_x_build_castle' '地标 · 晨曦花园城堡' '【地标档案：晨曦花园城堡】
【位置】绿谷星 (60, 79, -250)
【外观】石砖与玻璃构成的童话花园城堡：主塔、花园庭院、环形护城河。
【看点】主塔观景台看日出；花园里四季花卉（季节系统）轮换开放；夜晚城堡灯火通明——是绿谷的地标名片。
【拍照点】护城河对岸正南方向，能拍到整座城堡倒影。
【任务】抵达城堡并完成主线④的燃料任务后，这里就是你的后勤基地。' '档案馆把它称作“绿谷的心脏”：文明在花园里种下的第一颗种子，长成了这座城市。' 'minecraft:stone_brick_stairs' @(@{type='questlog:item_obtain'; item='minecraft:stone_bricks'; required_amount=16; name='为城堡备 16 块石砖'}) @(@{type='questlog:experience'; experience=40}) 'building' 43
New-Quest 'starciv_x_build_lighthouse' '地标 · 铁锈灯塔' '【地标档案：铁锈灯塔】
【位置】铁锈星 (480, 76, 460)
【外观】锈色废土上直插天穹的灯塔：红砖塔身、顶部灯室、螺旋外梯。
【看点】灯室在夜里发出醒目光束；塔顶平台可以远眺高炉群与推进器残骸；废土日落时灯影拉得很长，是铁锈星最出名的摄影点。
【任务】亲自登塔（任务：建筑线之二已完成者直接解锁）。' '灯塔不是说“这里亮着”，而是在说“还有人记得怎么亮”。' 'minecraft:lantern' @(@{type='questlog:item_obtain'; item='minecraft:lantern'; required_amount=2; name='备 2 个灯笼'}) @(@{type='questlog:experience'; experience=30}) 'building' 44
New-Quest 'starciv_x_build_pavilion' '地标 · 硅火霓虹亭' '【地标档案：硅火霓虹亭】
【位置】硅火星 (-660, 69, 360)
【外观】霓虹管的空中亭台：紫水晶柱+玻璃穹顶+LED 光带。
【看点】夜里整座亭子像悬浮的宝石；亭下广场有自动化展览（中央计算机群）。
【提示】这是硅火都市的“城市客厅”，完成主线⑥后可以常来。
【任务】带 8 枚紫水晶碎片来亭台装点（或直接参观）。' '硅火文明把技术写进了城市美学：霓虹不只是灯，是这座都市还在呼吸的证据。' 'minecraft:amethyst_block' @(@{type='questlog:item_obtain'; item='minecraft:amethyst_shard'; required_amount=8; name='收集 8 枚紫水晶碎片'}) @(@{type='questlog:item'; item='starciv:warp_core'; count=1}) 'building' 45
New-Quest 'starciv_x_build_skyship' '地标 · 苍穹空艇' '【地标档案：苍穹空艇】
【位置】苍穹星 (300, 64, -580)
【外观】悬浮大陆边缘停泊的大型空艇：木铁舰体、帆与气囊。
【看点】从甲板上俯瞰晶体森林全貌；云层在船底流过——全包最美景观位。
【任务】登上甲板并收集 4 枚紫水晶碎片（晶体森林随手可得）。
【提示】完成主线⑩后可达；返航绿谷可用这边风景当传送参照。' '档案馆的诗句：文明终究会长出翅膀。空艇不是用来逃离，而是用来俯瞰自己走过的路。' 'minecraft:oak_planks' @(@{type='questlog:item_obtain'; item='minecraft:amethyst_shard'; required_amount=4; name='收集 4 枚紫水晶碎片'}) @(@{type='questlog:experience'; experience=80}) 'building' 46
New-Quest 'starciv_x_build_tips' '手册 · 建筑与摄影' '【建筑指引】
  ① 想复古：石砖+橡木+灯笼，参考晨曦花园城堡
  ② 想科技：混凝土+玻璃+霓虹（紫水晶），参考硅火霓虹亭
  ③ 想自然：原木+藤蔓+花坛，参考绿谷农田
【摄影技巧】
  · 按 F1 隐藏界面截图
  · 日出/日落光线最好
  · 站在护城河/悬空岛边缘取中景
【任务】拍摄（或亲眼观赏）2 个地标——完成后你就是认证的建筑巡礼者。' '建筑是文明写给时间的信。写得好不好，百年后自有读者。' 'minecraft:map' @(@{type='questlog:item_craft'; item='minecraft:map'; required_amount=1; name='制作地图'}) @(@{type='questlog:experience'; experience=50}) 'building' 47

# ===== 维度 7（dimensions）=====
Write-Host "== 维度 7 =="
New-Quest 'starciv_s3_explore' '维度 · 星际远行' '维度线之一：亲访三颗星球。
【怎么做】从各星门依次传送【铁锈星】【硅火星】【苍穹星】各一次，每颗停留至少 1 分钟。
【推荐路线】铁锈（主线③后）→ 硅火（主线⑥后）→ 苍穹（主线⑩后）。
【为什么】三颗星球的景象与特产是主线之外不可错过的风景；也是后续百科任务的实地考察。
【提示】星门在绿谷独石碑旁；带好星门钥匙与跃迁引擎。' '四星文明从不是孤岛。档案馆给每位新晋升者的建议：走出去，亲眼看一看锈蚀的大地和霓虹的都市，然后你才会真正理解要守护的是什么。' 'minecraft:compass' @(@{type='questlog:visit_dimension'; dimension='starciv:rustfall'; required_amount=1; name='再访铁锈星'}, @{type='questlog:visit_dimension'; dimension='starciv:silicon'; required_amount=1; name='探访硅火星'}, @{type='questlog:visit_dimension'; dimension='starciv:stellaris'; required_amount=1; name='遨游苍穹星'}) @(@{type='questlog:experience'; experience=150}, @{type='questlog:item'; item='starciv:warp_core'; count=1}) 'dimensions' 50
New-Quest 'starciv_d2_rust_tour' '维度 · 铁锈巡礼' '维度线之二：深入铁锈星工业遗迹。
【干什么】① 探索至少一处大型工厂遗迹；② 收集 16 份【红石粉】（遗迹宝箱/矿脉）；③ 远眺高炉群。
【记住】你看到的每一座高炉，都是旧文明燃烧过的证明。
【提示】地标：铁锈灯塔 (480,76,460) 与灯塔周边废城。' '巡礼的意义在于记住：机械的辉煌与代价从来一体两面。档案馆希望每一位晋升者都亲眼见过，再决定自己要成为怎样的文明。' 'minecraft:redstone' @(@{type='questlog:item_obtain'; item='minecraft:redstone'; required_amount=16; name='收集 16 份红石粉'}, @{type='questlog:visit_dimension'; dimension='starciv:rustfall'; required_amount=1; name='重游铁锈星'}) @(@{type='questlog:experience'; experience=90}) 'dimensions' 51
New-Quest 'starciv_d3_stellar_crystals' '维度 · 苍穹水晶' '维度线之三：遨游苍穹星晶体森林。
【干什么】① 再次抵达苍穹星；② 在晶体森林采集 8 枚【紫水晶碎片】；③ 登上一座悬浮岛远眺。
【提示】晶体森林是苍穹最亮的地方，夜里像星河落在地面。
【注意】悬浮岛边缘没有护栏，别掉下去——掉进云层只会重生。' '苍穹星的晶体森林记录着星光的形状。档案馆的诗句：每摘下一枚水晶，就收藏了一束星光。' 'minecraft:amethyst_block' @(@{type='questlog:visit_dimension'; dimension='starciv:stellaris'; required_amount=1; name='遨游苍穹星'}, @{type='questlog:item_obtain'; item='minecraft:amethyst_shard'; required_amount=8; name='采集 8 枚紫水晶碎片'}) @(@{type='questlog:experience'; experience=110}) 'dimensions' 52
New-Quest 'starciv_x_planet_valley' '星球 · 绿谷' '【星球档案：绿谷星】
【定位】农业之星，你的出生地，文明的食物基地。
【生态】温带平原+河谷：麦田、果园、四季更替（季节系统）。
【特产】上古之种（独石碑脚下）、文明精华、四季作物。
【地标】晨曦花园城堡 (60,79,-250)、绿谷星门（独石碑旁）。
【玩法】农业（温室盆栽）、养蜂、酿酒、村民交易。
【主线地位】农业→燃料循环的起点；星门钥匙在此铸造。' '绿谷是四星中唯一保有远古种子的世界。档案馆写道：能种出粮食的文明，才配仰望星空。' 'minecraft:wheat' @(@{type='questlog:item_obtain'; item='minecraft:wheat'; required_amount=8; name='收获 8 个小麦'}) @(@{type='questlog:experience'; experience=30}) 'dimensions' 53
New-Quest 'starciv_x_planet_rust' '星球 · 铁锈' '【星球档案：铁锈星】
【定位】工业之星：锈红天空，钢铁废土。
【生态】荒漠+矿区：废弃工厂、高炉群、深埋紫水晶矿。
【特产】数据裂片（紫水晶研磨）、生物燃料（上古之种发酵）、红石。
【地标】铁锈灯塔 (480,76,460)。
【玩法】Create 传动、沉浸工程电网、高炉冶炼。
【主线地位】③④⑤ 步的主舞台：重启抛光线→收集数据裂片。
【注意】污染值会提醒你：工业必须与自然和解。' '铁锈星曾是旧文明的工业心脏。锈蚀的大地仍在回荡机械的呓语。' 'minecraft:iron_ingot' @(@{type='questlog:item_craft'; item='minecraft:blast_furnace'; required_amount=1; name='铸造高炉'}) @(@{type='questlog:experience'; experience=30}) 'dimensions' 54
New-Quest 'starciv_x_planet_silicon' '星球 · 硅火' '【星球档案：硅火星】
【定位】信息之星：霓虹都市，硅基文明巅峰。
【生态】都市+岩区：霓虹街道、中央计算机群、紫水晶矿脉。
【特产】数据裂片、红石灯、精密零件、量子科技。
【地标】硅火霓虹亭 (-660,69,360)。
【玩法】存储网络、电脑自动化、能量走廊。
【主线地位】⑥⑦⑧⑨ 步的主舞台：精密零件→量子核心→跃迁引擎。
【注意】信息是有生命的——读懂它，但别被它吞噬。' '硅火文明几乎抵达了“上传”的境界——他们把自己写进了数据。档案馆警告：读懂它，但别被它吞噬。' 'minecraft:redstone_lamp' @(@{type='questlog:item_craft'; item='minecraft:redstone_lamp'; required_amount=1; name='制作红石灯'}) @(@{type='questlog:experience'; experience=40}) 'dimensions' 55
New-Quest 'starciv_x_planet_stellaris' '星球 · 苍穹' '【星球档案：苍穹星】
【定位】星际终点：悬浮大陆与晶体森林。
【生态】悬浮岛、水晶林、云海。
【特产】紫水晶碎片、跃迁核心、远古造物战利品。
【地标】苍穹空艇 (300,64,-580)。
【玩法】火箭与空间站、跃迁引擎往返。
【主线地位】⑩⑪ 步：应许之地→终局仪式。
【威胁】守护者【下界合金巨兽】盘踞晶体平原；终局前务必全副武装。' '苍穹星不是终点，而是起点。档案馆的最后一页写着：文明的轮回在苍穹完成，而薪火将永远传递。' 'minecraft:elytra' @(@{type='questlog:item_obtain'; item='minecraft:amethyst_shard'; required_amount=4; name='收集 4 枚紫水晶碎片'}) @(@{type='questlog:experience'; experience=60}) 'dimensions' 56
New-Quest 'starciv_x_stargate' '手册 · 星门与跃迁' '【星际交通指南】
  · 星门（绿谷→铁锈/硅火）：手持【星门钥匙】走进星门
  · 苍穹之门（硅火→苍穹）：手持【跃迁引擎】启动
  · 返程：任何星门都可回绿谷（用钥匙）
【用什么做】星门钥匙=主线②；跃迁引擎=主线⑨。
【坐标卡】
  绿谷星门：独石碑旁（约 0,70,0 一带）
  苍穹之门：硅火中央广场
【任务】完成一次完整往返（绿谷→任一星球→回绿谷）。' '星门技术是第一代文明的赠礼：把四颗星球缝在同一条时间线上。' 'minecraft:ender_pearl' @(@{type='questlog:item_obtain'; item='minecraft:ender_pearl'; required_amount=2; name='收集 2 颗末影珍珠'}) @(@{type='questlog:experience'; experience=50}) 'dimensions' 57

# ===== 战斗 3（combat）=====
Write-Host "== 战斗 3 =="
New-Quest 'starciv_x_boss_leviathan' 'Boss · 深渊利维坦' '【Boss 档案：深渊利维坦】（Cataclysm）
【位置】深海生物群系（绿谷海沟/铁锈星海底遗迹）。
【外观】巨型海龙：长颈、利齿、潜伏水底。
【打法】
  ① 水战吃亏——把它引到浅水/岸上打
  ② 俯冲注意躲闪，贴身连击
  ③ 掉落物含【利维坦牙】，可合成强力武器
【准备】潜水装备（海龟壳/水下呼吸药水）、远程武器。
【奖励】高额经验 + 稀有材料。' '档案馆的海洋卷宗：旧文明在深海里埋了不止一座城市，也埋了不止一头守护者。' 'minecraft:water_bucket' @(@{type='questlog:entity_kill'; entity='cataclysm:the_leviathan'; required_amount=1; name='击败深渊利维坦'}) @(@{type='questlog:experience'; experience=800}) 'combat' 60
New-Quest 'starciv_x_boss_monstrosity' 'Boss · 下界合金巨兽（终局）' '【Boss 档案：下界合金巨兽】（终局守护者，主线⑪）
【位置】苍穹星晶体平原，骸骨环绕的巢穴。
【外观】四足机械巨兽：下界合金甲壳，流星火雨与冲锋是招牌。
【打法】
  ① 绕侧翼攻击后腿，正面会被碾压
  ② 火雨阶段找掩体（水晶柱）
  ③ 残血狂暴：拉开距离风筝，或上药水硬刚
【掉落】远超普通材料；任务奖励 4 跃迁核心。
【准备】全套下界合金 + 金苹果 + 喷溅治疗。
【剧情】击败它=完成终局仪式，四星灯塔同亮。' '守护者不是敌人，它是第一代文明留下的守门人。击败它并非征服，而是证明：新的文明已具备接过星火的资格。' 'minecraft:netherite_ingot' @(@{type='questlog:entity_kill'; entity='cataclysm:netherite_monstrosity'; required_amount=1; name='击败下界合金巨兽'}) @(@{type='questlog:experience'; experience=1500}, @{type='questlog:item'; item='starciv:warp_core'; count=2}) 'combat' 61
New-Quest 'starciv_x_boss_prep' '战斗 · 出战准备' '【出战清单】（打任何 Boss 前对照）
  装备：全套下界合金/更高品质，附魔 保护+锋利
  药水：力量、抗火、治疗喷溅、夜视（地下）
  食物：金苹果/炖汤（回满饱食）
  道具：末影珍珠（逃脱）、烟花（逃生）、盾牌（防御姿态）
【练手目标】先击败一次普通精英怪，熟悉战斗节奏。
【注意】Boss 战建议单人备份存档 / 多人约定复活点。' '胜败乃兵家常事，但准备是胜利的一半。档案馆给所有候补晋升者的忠告：别拿生命测试运气。' 'minecraft:golden_apple' @(@{type='questlog:item_craft'; item='minecraft:golden_apple'; required_amount=1; name='备好金苹果'}, @{type='questlog:item_obtain'; item='minecraft:shield'; required_amount=1; name='手拿盾牌'}) @(@{type='questlog:experience'; experience=120}) 'combat' 62

# ===== 知识 6（knowledge）=====
Write-Host "== 知识 6 =="
New-Quest 'starciv_g_guide' '指引 · 成为文明' '【总览】这是一本“星际文明编年史”任务书。
【怎么用】
  · 章节页签：主线 / 科技 / 动物 / 建筑 / 维度 / 战斗 / 知识
  · 每章按编号排序，从左到右即推荐流程
  · 主线带①②③序号，是通关主流程
【核心规则】绿谷(农业)→铁锈(工业)→硅火(信息)→苍穹(星际)；阶段可以提前游览，但升级材料一环扣一环。
【参考】手册《星际文明编年史·探索手册》随初始物品赠送，遗失可用【书+羽毛】合成。
【任务】拥有任意一本书（任务书/手册/普通书均可）。' '星港档案馆把四星文明的哲学写进了每一页。成为文明的第一步不是征服，而是理解——理解四季、理解机械、理解数据，最后理解星空。' 'minecraft:written_book' @(@{type='questlog:item_obtain'; item='minecraft:book'; required_amount=1; name='拥有任意书籍'}) @(@{type='questlog:experience'; experience=10}) 'knowledge' 70
New-Quest 'starciv_g_agriculture' '指引 · 绿谷农业' '【农业四季节奏】
  春：播种小麦/胡萝卜/土豆
  夏：护养+除草（作物疯长）
  秋：大丰收
  冬：温室（盆栽室内种植）维持供应
【进阶】
  · 养蜂（产物蜜蜂）→基因样本
  · 酿酒（酿造与烹饪）→村落经济
  · 村民交易（简易村民）→贸易网络
【任务】收获 16 个小麦。
【结论】农业是唯一能自我循环的起点——先吃饱，再远征。' '绿谷星的农田不是背景，而是文明的温床。能种出粮食的文明，才配仰望星空。' 'minecraft:wheat' @(@{type='questlog:item_craft'; item='minecraft:wheat'; required_amount=16; name='收获 16 个小麦'}) @(@{type='questlog:experience'; experience=25}) 'knowledge' 71
New-Quest 'starciv_g_industry' '指引 · 铁锈工业' '【工业三步曲】
  ① Create：传动轴+皮带→机械城（参见科技页签）
  ② 沉浸工程：高压电网→重工冶炼
  ③ 减排：污染值别爆表，绿植/过滤器可以压
【本包平衡】铁锈星的任务核心=产出与减排的平衡。
【任务】制作 2 个活塞（工业第一步）。
【提示】详细教程看【科技】章节。' '铁锈星教会文明一件事：力量需要代价。但旧文明正是败于对代价的傲慢。这一次，让机械服务于田园。' 'minecraft:piston' @(@{type='questlog:item_craft'; item='minecraft:piston'; required_amount=2; name='制作 2 个活塞'}) @(@{type='questlog:experience'; experience=30}) 'knowledge' 72
New-Quest 'starciv_g_information' '指引 · 硅火信息' '【信息四件套】
  ① 存储网络：统御万物
  ② 逻辑编程：收发数据
  ③ 电脑：让整座都市自动化
  ④ 能量走廊：终局电网
【主线结合】⑥⑦⑧⑨ 是实践课：精密零件→量子核心→跃迁引擎。
【任务】制作 1 个红石灯。
【警告】信息是有生命的——读懂它，但别被它吞噬。' '硅火文明几乎抵达了“上传”的境界——他们把自己写进了数据。档案馆警告：信息是有生命的。' 'minecraft:redstone_lamp' @(@{type='questlog:item_craft'; item='minecraft:redstone_lamp'; required_amount=1; name='制作红石灯'}) @(@{type='questlog:experience'; experience=40}) 'knowledge' 73
New-Quest 'starciv_g_interstellar' '指引 · 苍穹星际' '【星际三步】
  ① 火箭：火箭+空间站→跨星球航线
  ② 跃迁引擎：通往苍穹的唯一载体（主线⑨）
  ③ Cataclysm Boss：终局试炼（见【战斗】页签）
【终局】集齐四星科技的文明，才有资格举行终局仪式。
【任务】持有 1 个【跃迁核心】。
【结局彩蛋】仪式完成后，四星灯塔同亮——可以回绿谷山顶看全景。' '苍穹星不是终点，而是起点。文明的轮回在苍穹完成，而薪火将永远传递。' 'minecraft:elytra' @(@{type='questlog:item_obtain'; item='starciv:warp_core'; required_amount=1; name='持有跃迁核心'}) @(@{type='questlog:experience'; experience=50}) 'knowledge' 74
New-Quest 'starciv_x_overview' '总览 · 星际编年史' '【故事背景】
上古文明在四颗星球上留下星港与档案馆，随后消失。你——一名绿谷的开拓者——在独石碑下拾起【上古之种】，接过了文明的薪火。
【四星路线】
  绿谷星：农业与种子（你在这里出生）
  铁锈星：工业与燃料（③④⑤）
  硅火星：信息与量子（⑥⑦⑧⑨）
  苍穹星：跃迁与终局（⑩⑪）
【推荐顺序】
  主线 ①→⑪ 为主线通关；
  支线（科技/动物/建筑/维度）可平行推进；
  【知识】页签是全部玩法的说明书。
【任务】集齐 4 种星球特产各 1 份（种子/铁锭/红石/紫水晶碎片）。' '这不是一份公告，而是一份传承。档案馆的最后一行字写着：读完它的人，就是下一个档案馆。' 'minecraft:nether_star' @(@{type='questlog:item_obtain'; item='starciv:ancient_seed'; required_amount=1; name='持有上古之种'}, @{type='questlog:item_obtain'; item='minecraft:iron_ingot'; required_amount=1; name='持有铁锭'}, @{type='questlog:item_obtain'; item='minecraft:redstone'; required_amount=1; name='持有红石粉'}, @{type='questlog:item_obtain'; item='minecraft:amethyst_shard'; required_amount=1; name='持有紫水晶碎片'}) @(@{type='questlog:item'; item='starciv:civ_essence'; count=3}, @{type='questlog:experience'; experience=100}) 'knowledge' 75

Write-Host ""
$n = (Get-ChildItem $qdir -Filter *.json).Count
$nc = (Get-ChildItem $cdir -Filter *.json).Count
Write-Host ("✔ 共生成 " + $n + " 个任务 / " + $nc + " 个章节")
$bad = 0
Get-ChildItem $qdir -Filter *.json | ForEach-Object { try { Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null } catch { Write-Host ("!! " + $_.Name + " " + $_.Exception.Message); $bad++ } }
Write-Host ("JSON 校验失败: " + $bad)
$br2 = Get-ChildItem $qdir -Filter *.json | ForEach-Object { Select-String -Path $_.FullName -Pattern '$(' -SimpleMatch } | Select-Object -First 3
if ($br2) { Write-Host "!! 发现残留标记"; $br2 | ForEach-Object { Write-Host $_.Path } } else { Write-Host "OK 无残留富文本标记" }