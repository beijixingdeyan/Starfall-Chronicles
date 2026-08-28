// =============================================================
// Starfall Chronicles — 物品标签（供配方与逻辑引用）
// =============================================================

ServerEvents.tags('item', event => {
  // 星门燃料（跨文明流通物的总开关）
  event.add('starciv:stellar_fuel', 'starciv:biofuel_canister');
  // 文明核心物料
  event.add('starciv:civilization_materials', '#starciv:ancient_seeds');
  event.add('starciv:civilization_materials', '#starciv:civ_essences');
  event.add('starciv:civilization_materials', '#starciv:precision_parts');
  event.add('starciv:civilization_materials', '#starciv:quantum_cores');
  event.add('starciv:civilization_materials', '#starciv:warp_cores');
  event.add('starciv:civilization_materials', 'starciv:warp_engine');
});