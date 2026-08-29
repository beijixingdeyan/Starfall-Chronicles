// =============================================================
// Starfall Chronicles — 世界生成：星门、独石碑与五大宏伟地标
// 用 level.getBlock(x,y,z).set(...) 内存写入（远快于 setblock 命令），
// 支持数千方块级的大型结构而不会卡住服务器 tick。
// 建筑：绿谷=晨曦花园城堡 · 铁锈=锈岩灯塔 · 硅火=霓虹空中阁楼 · 苍穹=霄汉飞艇
// 规则：维度未就绪则延后重试，全部成功后才写 persistentData，绝不重复。
// =============================================================

function cmd(srv, dim, str) { srv.runCommandSilent('execute in ' + dim + ' run ' + str); }
function put(level, x, y, z, block) {
  try { level.getBlock(x, y, z).set(block); } catch (e) { /* 越界忽略 */ }
}
function findSurfaceY(srv, dim, x, z) {
  var level = srv.getLevel(dim);
  if (!level) return 64;
  for (var y = 200; y > -60; y--) {
    try {
      var b = String(level.getBlock(x, y, z).id);
      if (b !== 'minecraft:air' && b !== 'minecraft:cave_air' && b !== '') {
        var a1 = String(level.getBlock(x, y + 1, z).id);
        var a2 = String(level.getBlock(x, y + 2, z).id);
        if (a1 === 'minecraft:air' && a2 === 'minecraft:air') return y + 1;
      }
    } catch (e) { return 64; }
  }
  return 64;
}

// ---- 基础填充 ----
function fill(level, x0, y0, z0, x1, y1, z1, block) {
  for (var x = Math.min(x0, x1); x <= Math.max(x0, x1); x++)
    for (var y = Math.min(y0, y1); y <= Math.max(y0, y1); y++)
      for (var z = Math.min(z0, z1); z <= Math.max(z0, z1); z++)
        put(level, x, y, z, block);
}
function hollowBox(level, x0, y0, z0, x1, y1, z1, wall, air) {
  for (var x = Math.min(x0, x1); x <= Math.max(x0, x1); x++)
    for (var y = Math.min(y0, y1); y <= Math.max(y0, y1); y++)
      for (var z = Math.min(z0, z1); z <= Math.max(z0, z1); z++) {
        var edge = x === Math.min(x0, x1) || x === Math.max(x0, x1) || y === Math.min(y0, y1) || y === Math.max(y0, y1) || z === Math.min(z0, z1) || z === Math.max(z0, z1);
        put(level, x, y, z, edge ? wall : air);
      }
}
function ring(level, cx, y, cz, r, block) {
  for (var dx = -r; dx <= r; dx++) for (var dz = -r; dz <= r; dz++) {
    if (Math.round(Math.sqrt(dx * dx + dz * dz)) === r) put(level, cx + dx, y, cz + dz, block);
  }
}
function column(level, x, y0, y1, z, block) { for (var y = y0; y <= y1; y++) put(level, x, y, z, block); }
function towerBody(level, cx, y0, z, w, h, wall) {
  for (var y = y0; y < y0 + h; y++)
    for (var dx = -w; dx <= w; dx++) for (var dz = -w; dz <= w; dz++) {
      var edge = Math.abs(dx) === w || Math.abs(dz) === w;
      put(level, cx + dx, y, z + dz, edge ? wall : 'minecraft:air');
    }
}

// ==================== ① 晨曦花园城堡（绿谷） ====================
// 旑丽田园式城堡：外花圃、喷泉、主楼+四角塔+雉堞墙
function buildGardenCastle(srv, dim, cx, gy, cz) {
  var level = srv.getLevel(dim);
  var S = 'minecraft:stone_bricks', MS = 'minecraft:mossy_stone_bricks', CS = 'minecraft:chiseled_stone_bricks';
  var O = 'minecraft:oak_log', P = 'minecraft:oak_planks', GW = 'minecraft:glass_pane';
  var T = 'minecraft:torch', FL = 'minecraft:sea_lantern';
  var W = 'minecraft:water', LIL = 'minecraft:lily_pad';
  var ground = gy - 1;
  // --- 外花园环（半径 22，花圃带 + 石径）---
  for (var r = 8; r <= 22; r += 2) ring(level, cx, ground, cz, r, MS);
  ring(level, cx, ground, cz, 23, CS);
  // 花圃矩阵（四个象限的花田）
  var flowers = ['minecraft:poppy', 'minecraft:dandelion', 'minecraft:azure_bluet', 'minecraft:cornflower', 'minecraft:oxeye_daisy'];
  var fi = 0;
  for (var qx = -18; qx <= 18; qx += 4) for (var qz = -18; qz <= 18; qz += 4) {
    if (Math.abs(qx) < 7 && Math.abs(qz) < 7) continue;
    if (Math.abs(qx) === 18 || Math.abs(qz) === 18) continue;
    put(level, cx + qx, gy, cz + qz, flowers[fi++ % flowers.length]);
    put(level, cx + qx, ground, cz + qz, 'minecraft:grass_block');
  }
  // 喷泉（十字水池 + 中心柱灯）
  for (var dx = -3; dx <= 3; dx++) for (var dz = -3; dz <= 3; dz++) {
    if (Math.abs(dx) === 3 || Math.abs(dz) === 3) { put(level, cx + dx, gy - 1, cz + dz, S); put(level, cx + dx, gy, cz + dz, W); }
  }
  put(level, cx, gy, cz, LIL); put(level, cx + 1, gy, cz, LIL);
  column(level, cx, gy, gy + 4, cz, S); put(level, cx, gy + 5, cz, FL);
  // --- 围墙（38x38，雉堞）---
  var wx0 = cx - 19, wx1 = cx + 19, wz0 = cz - 19, wz1 = cz + 19;
  for (var x = wx0; x <= wx1; x++) for (var z = wz0; z <= wz1; z++) {
    var edge = x === wx0 || x === wx1 || z === wz0 || z === wz1;
    if (!edge) continue;
    for (var h = 0; h < 5; h++) put(level, x, gy + h, z, h < 3 ? S : (h === 3 ? MS : CS));
  }
  for (var x = wx0; x <= wx1; x += 3) { put(level, x, gy + 5, wz0, CS); put(level, x, gy + 5, wz1, CS); }
  for (var z = wz0; z <= wz1; z += 3) { put(level, wx0, gy + 5, z, CS); put(level, wx1, gy + 5, z, CS); }
  // --- 主楼（塔楼 11x11 x 高 20 + 四角塔 5x5 x 高 13）---
  towerBody(level, cx, gy, cz, 5, 18, S);
  fill(level, cx - 5, gy + 18, cz - 5, cx + 5, gy + 20, cz + 5, MS);
  for (var dx = -5; dx <= 5; dx += 1) { put(level, cx + dx, gy + 21, cz - 5, CS); put(level, cx + dx, gy + 21, cz + 5, CS); put(level, cx + dx, gy + 21, cz, CS); }
  // 窗与灯
  for (var y = gy + 3; y <= gy + 15; y += 3) {
    put(level, cx - 5, y, cz, GW); put(level, cx + 5, y, cz, GW); put(level, cx, y, cz - 5, GW); put(level, cx, y, cz + 5, GW);
    put(level, cx - 5, y, cz - 5, T); put(level, cx + 5, y, cz + 5, T); put(level, cx - 5, y, cz + 5, FL); put(level, cx + 5, y, cz - 5, FL);
  }
  // 主楼屋顶四角塔
  for (var i = 0; i < 4; i++) {
    var ax = (i % 2 === 0 ? -1 : 1) * 6, az = (i < 2 ? -1 : 1) * 6;
    towerBody(level, cx + ax, gy + 1, cz + az, 2, 11, S);
    put(level, cx + ax, gy + 12, cz + az, CS);
    column(level, cx + ax, gy + 13, gy + 15, cz + az, O);
    put(level, cx + ax, gy + 16, cz + az, FL);
  }
  // 入口拱廊（南侧）
  for (var h = 0; h < 4; h++) { put(level, cx - 1, gy + h, cz + 5, CS); put(level, cx + 1, gy + h, cz + 5, CS); }
  put(level, cx, gy + 4, cz + 5, CS);
  for (var h = 1; h <= 5; h++) { put(level, cx - 2, gy + h, cz + 5, S); put(level, cx + 2, gy + h, cz + 5, S); }
  put(level, cx, gy + 4 + 3, cz + 5, CS);
  for (var dx = -2; dx <= 2; dx++) for (var h = 0; h < 2; h++) put(level, cx + dx, gy + h, cz + 6, P);
  // 树木点缀
  var trees = [[cx - 14, cz - 12], [cx + 14, cz + 12], [cx + 12, cz - 14], [cx - 12, cz + 14]];
  for (var ti = 0; ti < trees.length; ti++) {
    var tx = trees[ti][0], tz = trees[ti][1];
    put(level, tx, gy, tz, 'minecraft:oak_sapling');
    put(level, tx, gy + 1, tz, 'minecraft:oak_log');
    for (var dx = -2; dx <= 2; dx++) for (var dz = -2; dz <= 2; dz++) {
      if (Math.abs(dx) === 2 || Math.abs(dz) === 2) put(level, tx + dx, gy + 3, tz + dz, 'minecraft:oak_leaves');
      else put(level, tx + dx, gy + 2, tz + dz, 'minecraft:oak_leaves');
    }
    put(level, tx, gy + 4, tz, 'minecraft:oak_leaves');
  }
  console.info('[Starfall] 晨曦花园城堡已建成 @ ' + dim + ' ' + cx + ',' + gy + ',' + cz);
}

// ==================== ② 锈岩灯塔（铁锈） ====================
// 工业废土上的高耸灯塔：基座+镂空塔身+顶端灯室+螺旋外梯
function buildRustLighthouse(srv, dim, cx, gy, cz) {
  var level = srv.getLevel(dim);
  var I = 'minecraft:iron_block', VI = 'minecraft:iron_bars', CB = 'minecraft:chiseled_stone_bricks';
  var B = 'minecraft:stone_bricks', RC = 'minecraft:red_concrete', DC = 'minecraft:dark_prismarine';
  var GS = 'minecraft:glowstone', SL = 'minecraft:sea_lantern', GL = 'minecraft:glass';
  var ground = gy - 1;
  // 基座环形平台
  for (var r = 4; r <= 10; r++) ring(level, cx, ground, cz, r, r === 10 ? CB : B);
  ring(level, cx, ground + 1, cz, 8, VI);
  // 塔身（7x7 实心砖柱，挖出螺旋窗）
  var H = 34;
  for (var y = gy + 1; y < gy + H; y++)
    for (var dx = -3; dx <= 3; dx++) for (var dz = -3; dz <= 3; dz++) {
      var edge = Math.abs(dx) === 3 || Math.abs(dz) === 3;
      put(level, cx + dx, y, cz + dz, edge ? B : 'minecraft:air');
    }
  // 螺旋窗（每 3 层一个观察窗 + 灯）
  for (var y = gy + 3, k = 0; y < gy + H - 4; y += 3, k++) {
    var side = k % 4;
    if (side === 0) put(level, cx, y, cz - 3, GL);
    else if (side === 1) put(level, cx + 3, y, cz, GL);
    else if (side === 2) put(level, cx, y, cz + 3, GL);
    else put(level, cx - 3, y, cz, GL);
    put(level, cx + 3, y - 1, cz + 3, 'minecraft:torch');
    put(level, cx - 3, y - 1, cz - 3, GS);
  }
  // 塔顶平台 + 灯室
  fill(level, cx - 4, gy + H, cz - 4, cx + 4, gy + H + 1, cz + 4, I);
  hollowBox(level, cx - 3, gy + H + 2, cz - 3, cx + 3, gy + H + 5, cz + 3, GL, 'minecraft:air');
  put(level, cx, gy + H + 6, cz, SL);
  put(level, cx, gy + H + 7, cz, SL);
  for (var dx = -3; dx <= 3; dx++) { put(level, cx + dx, gy + H + 5, cz - 3, CB); put(level, cx + dx, gy + H + 5, cz + 3, CB); put(level, cx, gy + H + 5, cz + dx, CB); }
  // 顶部灯笼环
  for (var r = 4; r <= 7; r++) ring(level, cx, gy + H + 6, cz, r, r % 2 === 0 ? GS : VI);
  // 基座工业装饰
  for (var r = 5; r <= 9; r += 2) { put(level, cx + r, ground + 1, cz, r % 2 === 0 ? DC : RC); }
  put(level, cx + 9, ground + 2, cz, VI);
  put(level, cx - 9, ground + 2, cz, VI);
  console.info('[Starfall] 锈岩灯塔已建成 @ ' + dim + ' ' + cx + ',' + gy + ',' + cz);
}

// ==================== ③ 霓虹空中阁楼（硅火） ====================
// 悬浮都市楼阁：石英基座 + 四角柱 + 悬空主阁 + 霓虹灯饰 + 高空观景桥
function buildNeonPavilion(srv, dim, cx, gy, cz) {
  var level = srv.getLevel(dim);
  var Q = 'minecraft:quartz_block', QB = 'minecraft:quartz_bricks', QP = 'minecraft:quartz_pillar';
  var A = 'minecraft:amethyst_block', AM = 'minecraft:amethyst_cluster';
  var NG = 'minecraft:magenta_stained_glass', NL = 'minecraft:sea_lantern', ST = 'minecraft:smooth_stone';
  var ground = gy - 1;
  // 地面基座
  var pad = 12;
  for (var dx = -pad; dx <= pad; dx++) for (var dz = -pad; dz <= pad; dz++) {
    put(level, cx + dx, ground, cz + dz, Q);
  }
  ring(level, cx, ground + 1, cz, pad, AM);
  // 四角柱（升到天空）
  var corn = [[-pad + 2, -pad + 2], [pad - 2, -pad + 2], [-pad + 2, pad - 2], [pad - 2, pad - 2]];
  for (var c = 0; c < corn.length; c++) {
    var px = cx + corn[c][0], pz = cz + corn[c][1];
    for (var y = gy + 1; y < gy + 34; y++) put(level, px, y, pz, QP);
    put(level, px, gy + 34, pz, NL);
    for (var y = gy + 4; y < gy + 32; y += 6) { put(level, px, y, pz, NG); }
  }
  // 悬空主阁（楼阁高 12，位于 34-46）
  var fly = gy + 34;
  hollowBox(level, cx - 9, fly, cz - 9, cx + 9, fly + 8, cz + 9, QB, 'minecraft:air');
  for (var yy = fly + 2; yy <= fly + 6; yy++) { put(level, cx - 9, yy, cz, NG); put(level, cx + 9, yy, cz, NG); put(level, cx, yy, cz - 9, NG); put(level, cx, yy, cz + 9, NG); }
  // 楼阁中庭灯柱
  column(level, cx, fly + 1, fly + 7, cz, QP);
  put(level, cx, fly + 8, cz, A);
  put(level, cx, fly + 9, cz, NL);
  // 上阁（第二层外挑环台）
  for (var dx = -11; dx <= 11; dx++) for (var dz = -11; dz <= 11; dz++) {
    var edge = Math.abs(dx) === 11 || Math.abs(dz) === 11;
    if (edge) put(level, cx + dx, fly + 9, cz + dz, ST);
  }
  for (var dx = -11; dx <= 11; dx += 4) { put(level, cx + dx, fly + 10, cz - 11, AM); put(level, cx + dx, fly + 10, cz + 11, AM); }
  // 悬空观景桥（至远处浮台）
  var bz = cz + 24;
  for (var z = cz + 9; z <= bz; z += 1) {
    if ((z - cz) % 4 === 0) put(level, cx, fly + 1, z, NL); else put(level, cx, fly + 1, z, ST);
  }
  fill(level, cx - 3, fly + 1, bz + 1, cx + 3, fly + 3, bz + 5, Q);
  put(level, cx, fly + 4, bz + 3, NL);
  console.info('[Starfall] 霓虹空中阁楼已建成 @ ' + dim + ' ' + cx + ',' + gy + ',' + cz);
}

// ==================== ④ 霄汉飞艇（苍穹） ====================
// 浮空飞艇：船体+桅帆+吊舱+锚链，悬浮于苍穹云海
function buildSkyship(srv, dim, cx, gy, cz) {
  var level = srv.getLevel(dim);
  var BODY = 'minecraft:smooth_stone', W = 'minecraft:white_concrete', Y = 'minecraft:yellow_terracotta';
  var F = 'minecraft:white_wool', F2 = 'minecraft:cyan_wool', M = 'minecraft:oak_log', K = 'minecraft:chain';
  var G = 'minecraft:glass', L = 'minecraft:sea_lantern';
  var ground = gy - 1;
  var fly = gy + 48;
  // 锚链（从船底垂到地面）
  for (var y = ground; y < fly - 8; y += 1) if (y % 3 === 0) put(level, cx, y, cz, K);
  put(level, cx, ground, cz, 'minecraft:anvil');
  // 主船体（长 20 宽 7 高 5）
  hollowBox(level, cx - 10, fly, cz - 3, cx + 10, fly + 4, cz + 3, BODY, 'minecraft:air');
  // 船首
  for (var dx = cx + 10; dx <= cx + 13; dx++) {
    var shrink = dx - (cx + 10);
    for (var dz = -3 + shrink; dz <= 3 - shrink; dz++) put(level, dx, fly + 2, cz + dz, BODY);
  }
  // 船尾
  for (var dx = cx - 10; dx >= cx - 14; dx--) {
    var shrink = (cx - 10) - dx;
    for (var dz = -3 + shrink; dz <= 3 - shrink; dz++) put(level, dx, fly + 2, cz + dz, W);
  }
  // 甲板
  fill(level, cx - 10, fly + 5, cz - 3, cx + 10, fly + 5, cz + 3, Y);
  // 沿舷灯
  for (var dx = cx - 10; dx <= cx + 10; dx += 4) { put(level, dx, fly + 5, cz - 3, L); put(level, dx, fly + 5, cz + 3, L); }
  // 桅杆（主桅 + 前桅）
  column(level, cx + 5, fly + 5, fly + 13, cz, M);
  column(level, cx - 5, fly + 5, fly + 11, cz, M);
  put(level, cx + 5, fly + 13, cz, L); put(level, cx - 5, fly + 11, cz, L);
  // 巨帆（白色 + 青色条纹，双片）
  for (var dx = -4; dx <= 4; dx++) for (var y = fly + 6; y <= fly + 12; y++) {
    put(level, cx + 5 + dx, y, cz + 2, dx % 2 === 0 ? F : F2);
    put(level, cx + 5 + dx, y, cz - 2, dx % 2 === 0 ? F2 : F);
  }
  for (var dx = -3; dx <= 3; dx++) for (var y = fly + 6; y <= fly + 10; y++) {
    put(level, cx - 5 + dx, y, cz + 2, dx % 2 === 0 ? F2 : F);
    put(level, cx - 5 + dx, y, cz - 2, dx % 2 === 0 ? F : F2);
  }
  // 吊舱（船腹下小屋）
  hollowBox(level, cx - 3, fly - 6, cz - 2, cx + 3, fly - 2, cz + 2, W, 'minecraft:air');
  fill(level, cx - 3, fly - 1, cz - 2, cx + 3, fly, cz + 2, W);
  for (var dz = -2; dz <= 2; dz++) { put(level, cx, fly - 5, cz + dz, G); }
  put(level, cx, fly - 4, cz + 2, G);
  put(level, cx, fly - 7, cz, L);
  // 尾翼
  for (var h = 1; h <= 4; h++) { put(level, cx - 15, fly + h, cz, W); put(level, cx - 15, fly + h, cz + 1, Y); }
  console.info('[Starfall] 霄汉飞艇已建成 @ ' + dim + ' ' + cx + ',' + gy + ',' + cz);
}

// ==================== 星门（保留）与独石碑（保留） ====================
function buildGate(srv, dim, cx, y, cz) {
  var level = srv.getLevel(dim);
  var S = 'minecraft:obsidian', G = 'minecraft:glowstone', C = 'starciv:stargate_core';
  var B = 'minecraft:stone_bricks', L = 'minecraft:sea_lantern';
  for (var dx = -2; dx <= 2; dx++) for (var dz = -2; dz <= 2; dz++) put(level, cx + dx, y - 1, cz + dz, B);
  for (var h = 0; h < 5; h++) {
    put(level, cx - 2, y + h, cz, S); put(level, cx + 2, y + h, cz, S);
    if (h === 1 || h === 3) { put(level, cx - 2, y + h, cz + 1, G); put(level, cx + 2, y + h, cz + 1, G); }
  }
  for (var dx = -1; dx <= 1; dx++) put(level, cx + dx, y + 4, cz, S);
  put(level, cx, y + 5, cz, G);
  for (var h = 1; h <= 3; h++) { put(level, cx - 1, y + h, cz, G); put(level, cx + 1, y + h, cz, G); }
  put(level, cx, y + 1, cz, C);
  put(level, cx - 2, y, cz - 2, L); put(level, cx + 2, y, cz - 2, L);
  put(level, cx - 2, y, cz + 2, L); put(level, cx + 2, y, cz + 2, L);
}

function buildMonolith(srv, dim, cx, y, cz) {
  var level = srv.getLevel(dim);
  var C = 'minecraft:chiseled_stone_bricks', P = 'minecraft:stone_brick_wall', G = 'minecraft:glowstone', A = 'minecraft:amethyst_block';
  for (var dx = -1; dx <= 1; dx++) for (var dz = -1; dz <= 1; dz++)
    for (var h = 0; h < 4; h++) put(level, cx + dx, y + h, cz + dz, C);
  put(level, cx, y + 4, cz, G);
  for (var dx = -1; dx <= 1; dx++) for (var dz = -1; dz <= 1; dz++) {
    if (dx === 0 && dz === 0) continue;
    put(level, cx + dx, y + 4, cz + dz, A);
  }
  for (var dx = -2; dx <= 2; dx++) for (var dz = -2; dz <= 2; dz++) {
    if (Math.abs(dx) === 2 || Math.abs(dz) === 2) put(level, cx + dx, y - 1, cz + dz, P);
  }
}

// ==================== 主流程 ====================
function buildStructures(evt) {
  try {
    var srv = evt.server || evt;
    if (srv.persistentData.sc_gates_built) return;
    var gates = [
      { id: 'valley', dim: 'minecraft:overworld', x: 0, z: -100, poi: 'castle', px: 60, pz: -150 },
      { id: 'rust', dim: 'starciv:rustfall', x: 200, z: 200, poi: 'lighthouse', px: 280, pz: 260 },
      { id: 'silicon', dim: 'starciv:silicon', x: -300, z: 150, poi: 'pavilion', px: -360, pz: 210 },
      { id: 'stellaris', dim: 'starciv:stellaris', x: 120, z: -260, poi: 'skyship', px: 180, pz: -320 }
    ];
    var map = {};
    for (var i = 0; i < gates.length; i++) {
      var g = gates[i];
      if (!srv.getLevel(g.dim)) continue;
      var gy = findSurfaceY(srv, g.dim, g.x, g.z) + 1;
      buildGate(srv, g.dim, g.x, gy, g.z);
      if (g.dim === 'minecraft:overworld') buildMonolith(srv, g.dim, g.x + 26, gy, g.z - 26);
      var py = findSurfaceY(srv, g.dim, g.x + g.px, g.z + g.pz) + 1;
      if (g.poi === 'castle') buildGardenCastle(srv, g.dim, g.x + g.px, py, g.z + g.pz);
      if (g.poi === 'lighthouse') buildRustLighthouse(srv, g.dim, g.x + g.px, py, g.z + g.pz);
      if (g.poi === 'pavilion') buildNeonPavilion(srv, g.dim, g.x + g.px, py, g.z + g.pz);
      if (g.poi === 'skyship') buildSkyship(srv, g.dim, g.x + g.px, py, g.z + g.pz);
      map[g.id] = { dim: g.dim, x: g.x, y: gy, z: g.z };
    }
    srv.persistentData.sc_gates_built = true;
    srv.persistentData.sc_gates = map;
    console.info('[Starfall] 星门与五大宏伟地标已生成: ' + JSON.stringify(map));
    srv.runCommandSilent('tellraw @a {"text":"§6【文明编年史】§f星门点亮，五大宏伟地标拔地而起——花园城堡·锈岩灯塔·霓虹阁楼·霄汉飞艇！","color":"gold"}');
  } catch (e) {
    console.error('[Starfall] 地标生成失败(不影响启动): ' + e);
  }
}
ServerEvents.loaded(buildStructures);