// =============================================================
// Starfall Chronicles — 绿谷星（农耕文明）配方
// 起点：上古之种 → 文明精粹 → 星门钥匙
// =============================================================

ServerEvents.recipes(event => {
  const { shapeless } = event;

  // 古法压榨（4 上古之种 → 1 文明精粹）与星门钥匙的配方位于数据包
  // data/starciv/recipes/（civ_essence_from_seed.json / stellar_key.json），
  // 稳定且被任务书 crafting 页引用（starciv:civ_essence_from_seed / starciv:stellar_key）。

  // 农夫乐事联动：上古之种可做沙拉原料（叙事：种子养活第一代殖民者）
  shapeless('minecraft:wheat_seeds', ['starciv:ancient_seed']);

  // 农耕星辰光：季节提醒（Serene Seasons 联动的小彩蛋，不锁阶段）
  // 直接用原版材料即可，无需额外合成。
});