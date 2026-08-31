// =============================================================
// Starfall Chronicles — 上古作物自动生长逻辑
// =============================================================

// 记录已扫描过的 chunks，避免重复检查
var scannedChunks = new java.util.HashSet();

BlockEvents.cropGrow(event => {
  try {
    if (String(event.block.id) !== 'starciv:ancient_crop') return;
    
    var age = event.block.properties.age || 0;
    if (age >= 3) return; // 已成熟
    
    // 15% 概率每 tick 生长（平均 7 ticks = 0.35 秒，实际游戏时间中雨天快两倍）
    if (Math.random() < 0.15) {
      event.block.set('starciv:ancient_crop', { age: Math.min(age + 1, 3) });
    }
  } catch (e) {
    console.warn('[Starfall] ancient crop grow error: ' + e);
  }
});

console.info('[Starfall] 上古作物自动生长已注册');
