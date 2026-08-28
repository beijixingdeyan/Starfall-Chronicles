// =============================================================
// Starfall Chronicles — 绿谷星（农耕文明）配方
// 起点：上古之种 → 文明精粹 → 星门钥匙
// =============================================================

ServerEvents.recipes(event => {
  const { shapeless, shaped } = event;

  // 古法压榨：4 上古之种 → 1 文明精粹（绿谷星可做）
  shapeless('1x starciv:civ_essence', ['4x starciv:ancient_seed']);

  // 星门钥匙：文明的启蒙仪式（绿谷星可做）
  // 金 = 太阳，绿宝石 = 绿谷，石英 = 星尘，精粹 = 文明记忆
  shaped('1x starciv:stellar_key', [
    'GEG',
    'EQE',
    'GEG'
  ], {
    G: 'minecraft:gold_ingot',
    E: 'minecraft:emerald',
    Q: 'starciv:civ_essence'
  });

  // 农夫乐事联动：上古之种可做沙拉原料（叙事：种子养活第一代殖民者）
  shapeless('minecraft:wheat_seeds', ['starciv:ancient_seed']);

  // 农耕星辰光：季节提醒（Serene Seasons 联动的小彩蛋，不锁阶段）
  // 直接用原版材料即可，无需额外合成。
});