// =============================================================
// Starfall Chronicles — 上古之种种植机制
// 玩家持上古之种，右键耕地（farmland）→ 放置上古作物方块
// 方块自动生长（4 阶段），成熟后右键收获 → 掉落上古之种 ×1 + 精粹 ×1
// =============================================================

PlayerEvents.rightClickBlock(event => {
  try {
    var p = event.player;
    if (p.creative) return;
    
    var blockId = String(event.block.id);
    var itemId = String(event.item.id);
    
    // 检查：玩家持上古之种 + 右键耕地
    if (itemId !== 'starciv:ancient_seed') return;
    if (blockId !== 'minecraft:farmland') return;
    
    event.cancel();
    
    // 在这个方块上方放置上古作物
    var placeBlock = event.block.offset(0, 1, 0);
    if (String(placeBlock.id) !== 'minecraft:air') return; // 上方必须是空气
    
    placeBlock.set('starciv:ancient_crop', { age: 0 });
    
    // 消耗手中的种子
    if (!p.creative) {
      p.inventory.removeItem(event.item);
    }
    
    p.tell('§6你在耕地上种下了上古之种。§7（等待 5-15 分钟，方块会自动生长；雨天加快生长；成熟后右键收获）');
  } catch (e) {
    console.warn('[Starfall] ancient seed planting error: ' + e);
  }
});

// 右键收获成熟的上古作物
PlayerEvents.rightClickBlock(event => {
  try {
    var blockId = String(event.block.id);
    if (blockId !== 'starciv:ancient_crop') return;
    
    var age = event.block.properties.age || 0;
    if (age < 3) { // 未成熟
      event.player.tell('§7上古作物还在生长中... （生长阶段 ' + age + ' / 3）');
      return;
    }
    
    event.cancel();
    
    // 成熟！收获
    event.block.set('minecraft:air');
    event.player.give(Item.of('starciv:ancient_seed', 1));
    event.player.give(Item.of('starciv:civ_essence', 1)); // 直接掉文明精粹，简化流程
    event.player.tell('§6【收获】上古之种 ×1、文明精粹 ×1。');
    
    // XP 奖励
    event.player.giveExperienceLevels(1);
  } catch (e) {
    console.warn('[Starfall] ancient crop harvest error: ' + e);
  }
});

console.info('[Starfall] 上古之种种植机制已注册');

// ---- 上古作物自动生长 ----
BlockEvents.cropGrow(event => {
  try {
    if (String(event.block.id) !== 'starciv:ancient_crop') return;
    var age = event.block.properties.age || 0;
    if (age >= 3) return;
    var growChance = event.level.isRaining() ? 0.30 : 0.15;
    if (Math.random() < growChance) {
      event.block.set('starciv:ancient_crop', { age: Math.min(age + 1, 3) });
    }
  } catch (e) { console.warn('[Starfall] crop grow: ' + e); }
});