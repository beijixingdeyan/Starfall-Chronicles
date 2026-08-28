// =============================================================
// Starfall Chronicles — 铁锈星（工业文明）配方
// 主打：工业炼化（生物燃料）、Mekanism 富集、精密零件
// =============================================================

ServerEvents.recipes(event => {
  const { shaped, shapeless } = event;

  // ---- 生物燃料：上古之种 × 2 + 煤炭 + 玻璃瓶（铁锈星工业炼化）----
  // 跨文明核心循环：绿谷星的种子，在工业星球变成星门燃料。
  // （本 KubeJS 构建对 create:mixing 构造器签名不兼容，生物燃料改为数据包
  //  data/starciv/recipes/biofuel_canister.json；此处保留叙事注释。）
  // ---- Mekanism 富集上古之种（工业级产能）----
  // 1 粒种子在净化机中产出 4 精粹：配方位于数据包 data/starciv/recipes/enrich_seed.json。

  // ---- 精密零件：铁板 + 红石 + 金粉（工业文明解锁）----
  // 信息文明的基石。create:iron_sheet 由 Create 辊压铁锭产生。
  shaped('2x starciv:precision_parts', [
    'SRG'
  ], {
    S: 'create:iron_sheet',
    R: 'minecraft:redstone',
    G: 'mekanism:dust_gold'
  }).stage('industrial');

  // ---- 沉浸工程风格辅助合成是没有的：IE 机器配方保持原版进度 ----
  // 提示：蒸汽火车（Create: Steam 'n' Rails）是铁锈星跨矿区运输的正道。
});