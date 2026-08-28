// =============================================================
// Starfall Chronicles — 硅火星（信息文明）配方
// 主打：AE2 / CC:Tweaked / 数据碎晶 / 量子核心
// =============================================================

ServerEvents.recipes(event => {
  const { shaped, shapeless } = event;

  // ---- 数据碎晶：紫水晶研磨（信息文明的原材料）----
  // Create 碾磨机 / Mekanism 粉碎机配方位于数据包
  // data/starciv/recipes/（mill_amethyst.json / crush_amethyst.json）。
  // （注：本 KubeJS 构建对 create:milling / mekanism:crushing 的构造器签名不兼容，
  //  数据包 JSON 是这些机器配方的稳定载体。）

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