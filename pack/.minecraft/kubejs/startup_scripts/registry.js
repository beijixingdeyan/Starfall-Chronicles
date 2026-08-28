// =============================================================
// Starfall Chronicles — Startup 注册：自定义物品与方块
// 命名空间 starciv（Stellar Civilization / 星际文明）
// 所有物品/方块纹理由 scripts/build_textures.ps1 生成，
// 位于资源包 assets/starciv/textures/。
// =============================================================

// 一、文明道具（跨文明合成链的核心物料）
StartupEvents.registry('item', event => {
  event.create('starciv:ancient_seed', 'basic')
    .displayName('上古之种')
    .texture('starciv:item/ancient_seed')
    .maxStackSize(64)
    .rarity('epic')
    .tag('starciv:ancient_seeds')
    .tooltip('§7它是绿谷星上古文明留下的最后遗产。')
    .tooltip('§6种下去，或者碾碎它——提炼文明精粹。');

  event.create('starciv:civ_essence', 'basic')
    .displayName('文明精粹')
    .texture('starciv:item/civ_essence')
    .maxStackSize(64)
    .rarity('rare')
    .tag('starciv:civ_essences')
    .tooltip('§6一粒种子中蕴含着一整个文明的知识结晶。');

  event.create('starciv:stellar_key', 'basic')
    .displayName('星门钥匙')
    .texture('starciv:item/stellar_key')
    .maxStackSize(1)
    .rarity('epic')
    .tag('starciv:stellar_keys')
    .tooltip('§b在绿谷星的星门核心处右键，开启前往铁锈星的旅程。')
    .tooltip('§7钥匙会回应持有者的文明阶段。');

  event.create('starciv:biofuel_canister', 'basic')
    .displayName('生物燃料罐')
    .texture('starciv:item/biofuel_canister')
    .maxStackSize(16)
    .rarity('common')
    .tag('starciv:stellar_fuel')
    .tooltip('§6上古之种发酵而成的星门燃料。§7（工业文明阶段）');

  event.create('starciv:data_slivers', 'basic')
    .displayName('数据碎晶')
    .texture('starciv:item/data_slivers')
    .maxStackSize(64)
    .rarity('common')
    .tag('starciv:data_slivers')
    .tooltip('§b紫水晶研磨出的信息载体——硅火星的通用货币。');

  event.create('starciv:precision_parts', 'basic')
    .displayName('精密零件')
    .texture('starciv:item/precision_parts')
    .maxStackSize(64)
    .rarity('uncommon')
    .tag('starciv:precision_parts')
    .tooltip('§7铁锈星机床的产物。§6信息文明的基石。');

  event.create('starciv:quantum_core', 'basic')
    .displayName('量子核心')
    .texture('starciv:item/quantum_core')
    .maxStackSize(16)
    .rarity('rare')
    .tag('starciv:quantum_cores')
    .tooltip('§d由精密零件锻造的 AI 核心。§7跃迁引擎的灵魂组件。');

  event.create('starciv:warp_core', 'basic')
    .displayName('跃迁核心')
    .texture('starciv:item/warp_core')
    .maxStackSize(16)
    .rarity('epic')
    .tag('starciv:warp_cores')
    .tooltip('§d扭曲时空的引擎之心——下一步，星辰大海。');

  event.create('starciv:warp_engine', 'basic')
    .displayName('跃迁引擎')
    .texture('starciv:item/warp_core') // 复用核心纹理，引擎成品以tooltip区分
    .maxStackSize(1)
    .rarity('epic')
    .tooltip('§d终局引擎：燃烧 AI 核心驱动曲率航行。')
    .tooltip('§6它让单个文明越过苍穹。');
});

// 二、星门核心方块（星门传送的交互点）
StartupEvents.registry('block', event => {
  event.create('starciv:stargate_core', 'basic')
    .displayName('星门核心')
    .textureAll('starciv:block/stargate_core')
    .hardness(10.0)
    .resistance(3600000.0)
    .lightLevel(1.0)          // 亮度 15
    .requiresTool()
    .noValidSpawns(true)
    .tagBlock('minecraft:mineable/pickaxe')
    .tagBlock('minecraft:needs_iron_tool');
});

console.info('[Starfall] 文明物品注册完成');