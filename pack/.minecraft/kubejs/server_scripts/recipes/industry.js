// =============================================================
// Starfall Chronicles — 铁锈星（工业文明）配方
// 主打：Create 混合（生物燃料）、Mekanism/工业原料、精密零件
// =============================================================

ServerEvents.recipes(event => {
  const { shaped, shapeless } = event;

  // ---- 生物燃料：上古之种 × 2 + 煤炭（Create 加热混合）----
  // 跨文明核心循环：绿谷星的种子，在工业星球变成星门燃料。
  event.recipes.create.mixing(
    Item.of('starciv:biofuel_canister', 1),
    ['2x starciv:ancient_seed', 'minecraft:coal']
  ).heated().stage('industrial');

  // ---- 精密零件：铁板 + 红石 + 金粉（工业文明解锁）----
  // 信息文明的基石。create:iron_sheet 由 Create 辊压铁锭产生。
  shaped('2x starciv:precision_parts', [
    'SRG'
  ], {
    S: 'create:iron_sheet',
    R: 'minecraft:redstone',
    G: 'mekanism:dust_gold'
  }).stage('industrial');

  // ---- 熔炉效率：Mekanism 富集上古之种（工业级产能）----
  // 1 粒种子在 Mekanism 净化机中可产出 4 精粹（绿谷手压仅 1/4 效率）
  event.recipes.mekanism.enriching('4x starciv:civ_essence', 'starciv:ancient_seed')
    .stage('industrial');

  // ---- 沉浸工程风格辅助合成是没有的：IE 机器配方保持原版进度 ----
  // 提示：蒸汽火车（Create: Steam 'n' Rails）是铁锈星跨矿区运输的正道。
});