// =============================================================
// Starfall Chronicles — 上古之种种植机制
// 玩家持上古之种，右键耕地（farmland）→ 放置上古作物方块
// 方块自动生长（4 阶段），成熟后右键收获 → 掉落上古之种 ×1 + 精粹 ×1
// 兼容 KubeJS 6.5 (Forge 1.20.1)：BlockEvents.rightClicked
// =============================================================

BlockEvents.rightClicked(event => {
  try {
    var p = event.player;
    if (!p || p.creative) return;

    var blockId = String(event.block.id);
    var item = event.item;
    var itemId = item ? String(item.id) : '';

    // 分支一：持上古之种 + 右键耕地 → 种植
    if (itemId === 'starciv:ancient_seed' && blockId === 'minecraft:farmland') {
      event.cancel();
      var placeBlock = event.block.offset(0, 1, 0);
      if (String(placeBlock.id) !== 'minecraft:air') return;
      placeBlock.set('starciv:ancient_crop', { age: 0 });
      if (!p.creative) {
        p.inventory.clear('starciv:ancient_seed', 1);
      }
      p.tell('§6你在耕地上种下了上古之种。§7（等待 5-15 分钟，方块会自动生长；雨天加快生长；成熟后右键收获）');
      return;
    }

    // 分支二：右键成熟的上古作物 → 收获
    if (blockId === 'starciv:ancient_crop') {
      var age = event.block.properties.age || 0;
      if (age < 3) {
        p.tell('§7上古作物还在生长中... （生长阶段 ' + age + ' / 3）');
        return;
      }
      event.cancel();
      event.block.set('minecraft:air');
      p.give(Item.of('starciv:ancient_seed', 1));
      p.give(Item.of('starciv:civ_essence', 1));
      p.tell('§6【收获】上古之种 ×1、文明精粹 ×1。');
      p.giveExperienceLevels(1);
    }
  } catch (e) {
    console.warn('[Starfall] ancient seed planting/harvest error: ' + e);
  }
});

console.info('[Starfall] 上古之种种植机制已注册');
