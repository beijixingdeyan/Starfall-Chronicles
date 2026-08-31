// =============================================================
// Starfall Chronicles — 星门交互：右键星门（核心或门框任意方块）发起跃迁
// 规则表见 settings.js warp_rules：
//   valley→rust     (首航需星门钥匙)
//   rust→silicon    需工业文明阶段 + 消耗 1 生物燃料罐
//   silicon→stellaris 需信息文明阶段
//   stellaris→valley 自由返航
// v1.1.1：触发面扩大到门框（黑曜石/萤石/核心都算），距离放宽到 64 格，
//         找不到星门时给出坐标引导，独石碑坐标来自 structures.js 的 sc_gates.monolith。
// =============================================================

function hasStage(p, stage) {
  try { return p.stages.has(stage); } catch (e) { return false; }
}
function countOf(p, id) {
  try { var c = p.inventory.countItem(id); if (c > 0) return c; } catch (e) {}
  try {
    var c = 0;
    var lists = [p.mainInventory, p.armor, p.offHand];
    for (var list of lists) {
      if (!list) continue;
      for (var slot of list) {
        if (slot && String(slot.id) === id) c += Number(slot.count || 1);
      }
    }
    return c;
  } catch (e2) { return 0; }
}
function consumeItem(server, playerName, id) {
  server.runCommandSilent('clear ' + playerName + ' ' + id + ' 1');
}

// 玩家是否真的站在某座星门附近（半径 64 内）
function nearestGate(p, gates) {
  var best = null, bestD = 64 * 64;
  for (var key of Object.keys(gates)) {
    var g = gates[key];
    if (!g || !g.x) continue;
    if (String(p.level.dimension) !== g.dim) continue;
    var dx = p.x - g.x, dy = p.y - g.y, dz = p.z - g.z;
    var d = dx * dx + dz * dz + dy * dy;
    if (d < bestD) { bestD = d; best = key; }
  }
  return best;
}

// 门框方块（右键任一块都触发跃迁引导）
var GATE_BLOCKS = ['starciv:stargate_core', 'minecraft:obsidian', 'minecraft:glowstone'];

BlockEvents.rightClicked(event => {
  try {
    var bid = String(event.block.id);
    if (GATE_BLOCKS.indexOf(bid) === -1) return;
    var p = event.player;
    var server = p.server;
    var gates = server.persistentData.sc_gates;
    if (!gates) { p.tell('§7星门尚未校准——稍等片刻（世界加载完成后星门会点亮）。'); return; }

    var gateId = nearestGate(p, gates);
    if (!gateId || !global.SC || !global.SC.warp_rules || !global.SC.warp_rules[gateId]) {
      // 引导：附近没有可用星门
      var dim = String(p.level.dimension);
      if (dim === 'minecraft:overworld') {
        p.tell('§c这里不是可用的星门。§7绿谷的星门在 §f(0, ~, -100)§7（独石碑旁，黑曜石门框中央有发光紫色核心）；');
        p.tell('§7请走到门框中央，右键 §b紫色发光核心 §7（或门框上的任意黑曜石/萤石）。');
      } else {
        p.tell('§c这里不是可用的星门。§7请在星球落点附近寻找黑曜石门框（见任务书【维度】页签的坐标）。');
      }
      return;
    }
    var rule = global.SC.warp_rules[gateId];
    var to = rule.to;
    if (!to) { p.tell('§c这条线路尚未开通。'); return; }

    // 冷却
    var now = Math.floor(Date.now() / 1000);
    var lastWarp = Number(p.persistentData.sc_lastWarp || 0);
    if (now - lastWarp < global.SC.warp_cooldown) { p.tell('§7星门还在重新充能……'); return; }

    var msg = (txt) => p.tell(txt);

    if (gateId === 'valley') {
      // 首航仪式：非工业文明必须持有星门钥匙
      var isVeteran = hasStage(p, global.SC.stages.industry);
      if (!isVeteran && countOf(p, 'starciv:stellar_key') < 1) {
        msg('§c星门核心需要§b星门钥匙§c才能唤醒。');
        msg('§7（先到独石碑 (26, ~, -126) 拿到上古之种 → 种出成熟后加工成文明精华 → 配合金锭绿宝石合成星门钥匙。）');
        return;
      }
      if (isVeteran) {
        msg('§6文明的守望者——铁锈星已为你敞开。');
      } else {
        msg('§b星门钥匙发出了共鸣。§6你踏入了绿谷星的晨曦之外。');
      }
    }

    if (rule.need_stage && !hasStage(p, rule.need_stage)) {
      msg('§c你的文明阶段尚未达到通行要求。');
      msg('§7（本线路需要阶段：§f' + rule.need_stage + '§7——完成对应主线任务即可获得。）');
      return;
    }
    if (rule.consume && countOf(p, rule.consume) < 1) {
      msg('§c星门缺少燃料：§6' + rule.consume + '§c。');
      msg('§7（铁锈星 → 硅火星需要 1 罐生物燃料。）');
      return;
    }

    // 燃料扣减 + 传送
    if (rule.consume) consumeItem(server, p.username, rule.consume);
    var target = gates[to];
    p.persistentData.sc_lastWarp = now;

    server.runCommandSilent(
      'execute in ' + target.dim + ' run tp ' + p.username + ' ' + target.x + ' ' + (target.y + 1) + ' ' + target.z
    );
    server.runCommandSilent(
      'execute in ' + target.dim + ' run spawnpoint ' + p.username + ' ' + target.x + ' ' + (target.y + 1) + ' ' + target.z
    );

    var names = {
      rust: ['铁锈星·工业文明', '浓烟之下，钢铁与蒸汽在轰鸣。污染防治是活下去的功课。'],
      silicon: ['硅火星·信息文明', '霓虹与算法。写错代码，工厂会爆炸。'],
      stellaris: ['苍穹星·星际文明', '戴森球与反物质。物理法则可以改写。'],
      valley: ['绿谷星·农耕文明', '麦田、酒香与四季。你回到了原点。']
    };
    var info = names[to] || [to, ''];
    server.scheduleInTicks(60, () => {
      server.runCommandSilent('title ' + p.username + ' title {"text":"§6' + info[0] + '","bold":true}');
    });
    server.runCommandSilent('execute as ' + p.username + ' run function starciv:arrive/' + to);
    msg('§6[跃迁完成] ' + info[0] + '. §7' + info[1]);
  } catch (e) {
    console.warn('[Starfall] stargate interact error: ' + e);
  }
});

// ---- 上古遗迹拜访：靠近独石碑 → 自动获得上古之种（跨文明起点）----
PlayerEvents.tick(event => {
  try {
    var p = event.player;
    var server = p.server;
    var gates = server && server.persistentData.sc_gates;
    if (!gates || !gates.monolith) return;
    if (String(p.level.dimension) !== gates.monolith.dim) return;

    var now = Math.floor(Date.now() / 1000);
    var last = Number(p.persistentData.sc_monolithVisit || 0);
    if (now - last < global.SC.monolith_cooldown) return;

    var m = gates.monolith;
    var dx = p.x - m.x, dy = p.y - m.y, dz = p.z - m.z;
    if (dx * dx + dy * dy + dz * dz > 26 * 26) return;

    p.persistentData.sc_monolithVisit = now;
    p.give(Item.of('starciv:ancient_seed', 2));
    server.runCommandSilent('advancement grant ' + p.username + ' only starciv:agriculture/explore_ruin');
    p.tell('§6【文明编年史】独石碑的低语在你脑海中苏醒：');
    p.tell('§7“§o...这是种子。文明的种子。它记得每一个时代。§r”');
    p.tell('§6你获得了 2 粒§b上古之种§6。');
    p.tell('§7任务书（Q 键）→【主线】→ ① 会指导你下一步：种下种子 → 做星门钥匙 → 去旁边的星门。');
  } catch (e) {
    console.warn('[Starfall] monolith tick error: ' + e);
  }
});