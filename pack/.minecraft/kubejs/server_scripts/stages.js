// =============================================================
// Starfall Chronicles — 文明阶段系统
// 阶段（stage）由“抵达新星球”触发，通过 tick 轮询维度实现
// （不依赖任何版本敏感的维度切换事件，最稳定）。
// 阶段控制：配方解锁（RecipeEventJS .stage()）、星门传送权限、
//           以及环境叙事文本。
// =============================================================

function isIn(level, dimId) {
  try { return String(level.dimension) === dimId; } catch (e) { return false; }
}

// 每玩家每 2 秒检查一次所在维度
PlayerEvents.tick(event => {
  try {
    var p = event.player;
    if (p.server === null || p.player === null) return;

    var now = Math.floor(Date.now() / 1000);
    var pd = p.persistentData;
    var last = Number(pd.sc_lastDimCheck || 0);
    if (now - last < 2) return;
    pd.sc_lastDimCheck = now;

    // 绿谷星：人人皆初始文明（农业）
    if (!p.stages.has(global.SC.stages.agriculture)) {
      p.stages.add(global.SC.stages.agriculture);
    }

    var dim = isIn(p.level, global.SC.dims.rust) ? 'rust'
              : isIn(p.level, global.SC.dims.silicon) ? 'silicon'
              : isIn(p.level, global.SC.dims.stellaris) ? 'stellaris' : 'valley';

    if (dim === 'rust' && !p.stages.has(global.SC.stages.industry)) {
      p.stages.add(global.SC.stages.industry);
      p.tell('§6【文明编年史】你踏上了铁锈星。浓烟与锈蚀之间，工业文明接纳了你。');
      p.tell('§7 阶段解锁：§f工业文明。配方与星门权限已更新。');
    }
    if (dim === 'silicon' && !p.stages.has(global.SC.stages.information)) {
      p.stages.add(global.SC.stages.information);
      p.tell('§d【文明编年史】硅火星的霓虹在你脚下延伸。代码，就是这里的力量。');
      p.tell('§7 阶段解锁：§f信息文明。配方与星门权限已更新。');
    }
    if (dim === 'stellaris' && !p.stages.has(global.SC.stages.interstellar)) {
      p.stages.add(global.SC.stages.interstellar);
      p.tell('§d【文明编年史】苍穹星。物理法则在这里可以被改写。你已抵达文明之巅。');
      p.tell('§7 阶段解锁：§f星际文明。终局内容已开放。');
    }
  } catch (e) {
    console.warn('[Starfall] stages tick error: ' + e);
  }
});