// =============================================================
// Starfall Chronicles — 硅火星（信息文明）配方
// 主打：AE2 / CC:Tweaked / 数据碎晶 / 量子核心
// =============================================================

ServerEvents.recipes(event => {
  const { shaped, shapeless } = event;

  // ---- 数据碎晶：紫水晶研磨（信息文明的原材料）----
  // Create 粉碎轮 / 碾磨机处理紫水晶碎片
  event.recipes.create.milling('4x starciv:data_slivers', 'minecraft:amethyst_shard')
    .stage('information');

  event.recipes.mekanism.crushing('4x starciv:data_slivers', 'minecraft:amethyst_shard')
    .stage('information');

  // ---- 量子核心：精密零件 ×2 + AE2 计算处理器 + 钻石 + 红石块 ----
  // 跨文明核心循环：铁锈星的精密零件，在硅火星变成 AI 核心。
  shapeless('1x starciv:quantum_core', [
    '2x starciv:precision_parts',
    'ae2:calculation_processor',
    'minecraft:diamond',
    'minecraft:redstone_block'
  ]).stage('information');

  // ---- CC:Tweaked 联动彩蛋：红石电路版致敬 ----
  shaped('1x ae2:logic_processor', [
    'R',
    'I'
  ], {
    R: 'minecraft:redstone',
    I: 'minecraft:iron_ingot'
  }).stage('information');

  // ---- 分支提示：AE2 与 Refined Storage 二选一专精，避免重复建设 ----
});