// =============================================================
// Starfall Chronicles — 世界生成：星门、独石碑、五大宏伟地标
//                 + 流动河流 + 分散驿站 + waystone 传送石
// 用 level.getBlock(x,y,z).set(...) 内存写入（远快于 setblock），
// 支持数千方块级的大型结构。
// 建筑：绿谷=晨曦花园城堡 · 铁锈=锈岩灯塔 · 硅火=霓虹空中阁楼 · 苍穹=霄汉飞艇
// 驿站：农庄小屋(绿谷) / 废土哨站(铁锈) / 霓虹商栈(硅火) / 歇脚亭(苍穹)
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
function log(level) { }

// ==================== 流动河流（绿谷） ====================
// 蜿蜒河道：从高处流向低处，水流自然下落形成流动动画。
// 沿 z 前进，x 用正弦偏移蜿蜒，每段 y 递减形成坡度。
function buildRiver(srv, dim, sx, topY, sz, len, dropPerStep) {
  var level = srv.getLevel(dim);
  if (!level) return;
  var W = 'minecraft:water', G = 'minecraft:gravel', S = 'minecraft:stone';
  var F = ['minecraft:poppy', 'minecraft:dandelion', 'minecraft:azure_bluet', 'minecraft:cornflower'];
  var y = topY, x = sx, z = sz, fi = 0;
  for (var i = 0; i < len; i++) {
    // 蜿蜒偏移
    x = sx + Math.round(Math.sin(i * 0.55) * 5);
    var step = Math.round(dropPerStep * (i % 2 === 0 ? 1 : 0.5));
    y = topY - Math.floor(i * (dropPerStep * 1.4));
    // 挖河床（3 格宽 2 格深）
    for (var dx = -1; dx <= 1; dx++) for (var dy = 0; dy <= 2; dy++) put(level, x + dx, y - dy, z, 'minecraft:air');
    // 河底铺碎石
    put(level, x, y - 3, z, G); put(level, x - 1, y - 3, z, G); put(level, x + 1, y - 3, z, G);
    // 放水（source，向低处自然流动）
    for (var dx2 = -1; dx2 <= 1; dx2++) put(level, x + dx2, y, z, W);
    put(level, x, y - 1, z, W);
    // 两岸边缘
    put(level, x - 2, y, z, S); put(level, x + 2, y, z, S);
    if (i % 3 === 0) { put(level, x - 2, y + 1, z, F[fi++ % F.length]); put(level, x + 3, y + 1, z, F[fi++ % F.length]); }
    z += 2;
  }
  console.info('[Starfall] 流动河流已建成 @ ' + dim + ' 起点 ' + sx + ',' + topY + ',' + sz + ' 长 ' + len);
}

// ==================== 驿站建筑（分散点缀，每维度一个风格） ====================
// 绿谷·农庄小屋：橡木框架 + 麦田 + 风车
function buildFarmhouse(srv, dim, cx, gy, cz) {
  var level = srv.getLevel(dim);
  var O = 'minecraft:oak_log', P = 'minecraft:oak_planks', ST = 'minecraft:stone_bricks';
  var G = 'minecraft:glass_pane', T = 'minecraft:torch', W = 'minecraft:wheat';
  var ground = gy - 1;
  // 小屋 7x5x5
  hollowBox(level, cx - 3, gy, cz - 2, cx + 3, gy + 4, cz + 2, O, 'minecraft:air');
  for (var y = gy + 1; y < gy + 4; y++) { put(level, cx - 3, y, cz, G); put(level, cx + 3, y, cz, G); }
  put(level, cx, gy, cz + 2, 'minecraft:oak_door');
  put(level, cx, gy + 5, cz, 'minecraft:oak_stairs');
  // 屋顶
  for (var dx = -4; dx <= 4; dx++) for (var h = 0; h < 2; h++) put(level, cx + dx, gy + 5 + h, cz - 1, P);
  for (var dx = -3; dx <= 3; dx++) put(level, cx + dx, gy + 6, cz, P);
  // 麦田 12x6
  for (var fx = -8; fx <= 8; fx += 2) for (var fz = -8; fz <= 8; fz += 2) {
    if (Math.abs(fx) < 4 && Math.abs(fz) < 3) continue;
    put(level, cx + fx, ground, cz + fz, 'minecraft:farmland');
    put(level, cx + fx, gy, cz + fz, W);
  }
  // 风车（小型）
  column(level, cx + 9, gy, gy + 8, cz, O);
  for (var d = 0; d < 4; d++) {
    var r = d % 2 === 0 ? 2 : 3;
    for (var h2 = 7; h2 <= 12; h2++) put(level, cx + 9 + (d === 0 ? r : 0), h2, cz + (d === 2 ? r : 0), P);
  }
  put(level, cx + 9, gy + 13, cz, T);
  console.info('[Starfall] 农庄驿站已建成 @ ' + dim + ' ' + cx + ',' + gy + ',' + cz);
}

// 铁锈·废土哨站：红砖哨塔 + 旗帜 + 熔炉屋
function buildWastelandOutpost(srv, dim, cx, gy, cz) {
  var level = srv.getLevel(dim);
  var B = 'minecraft:stone_bricks', R = 'minecraft:red_concrete', I = 'minecraft:iron_block';
  var G = 'minecraft:glass_pane', T = 'minecraft:torch', F = 'minecraft:furnace';
  var ground = gy - 1;
  for (var r = 3; r <= 7; r++) ring(level, cx, ground, cz, r, r % 2 === 0 ? B : R);
  // 哨塔 5x5 高 12
  towerBody(level, cx, gy, cz, 2, 11, B);
  for (var y = gy + 2; y <= gy + 10; y += 3) { put(level, cx - 2, y, cz, G); put(level, cx + 2, y, cz, G); }
  fill(level, cx - 2, gy + 11, cz - 2, cx + 2, gy + 12, cz + 2, R);
  put(level, cx, gy + 13, cz, T);
  // 塔顶旗帜（蓝色旗帜柱）
  column(level, cx, gy + 14, gy + 15, cz, I);
  // 熔炉屋 3x3
  hollowBox(level, cx + 6, gy, cz - 2, cx + 9, gy + 2, cz + 2, B, 'minecraft:air');
  put(level, cx + 7, gy, cz - 2, F); put(level, cx + 6, gy + 1, cz, G);
  console.info('[Starfall] 废土哨站已建成 @ ' + dim + ' ' + cx + ',' + gy + ',' + cz);
}

// 硅火·霓虹商栈：石英小铺 + 紫水晶灯
function buildNeonKiosk(srv, dim, cx, gy, cz) {
  var level = srv.getLevel(dim);
  var Q = 'minecraft:quartz_block', QP = 'minecraft:quartz_pillar', A = 'minecraft:amethyst_block';
  var NG = 'minecraft:magenta_stained_glass', SL = 'minecraft:sea_lantern';
  var ground = gy - 1;
  for (var dx = -4; dx <= 4; dx++) for (var dz = -4; dz <= 4; dz++) put(level, cx + dx, ground, cz + dz, Q);
  ring(level, cx, gy, cz, 4, A);
  // 展台
  for (var i = 0; i < 4; i++) {
    var ax = (i % 2 === 0 ? -1 : 1) * 3, az = (i < 2 ? -1 : 1) * 3;
    column(level, cx + ax, gy, gy + 2, cz + az, QP);
    put(level, cx + ax, gy + 3, cz + az, SL);
  }
  // 中心柱灯
  column(level, cx, gy, gy + 5, cz, QP);
  put(level, cx, gy + 6, cz, SL);
  // 玻璃穹顶
  hollowBox(level, cx - 3, gy + 4, cz - 3, cx + 3, gy + 6, cz + 3, NG, 'minecraft:air');
  console.info('[Starfall] 霓虹商栈已建成 @ ' + dim + ' ' + cx + ',' + gy + ',' + cz);
}

// 苍穹·歇脚亭：浮空石台 + 末地石柱 + 紫水晶挂灯
function buildSkyshipRest(srv, dim, cx, gy, cz) {
  var level = srv.getLevel(dim);
  var ES = 'minecraft:end_stone_bricks', P = 'minecraft:purpur_block';
  var A = 'minecraft:amethyst_block', SL = 'minecraft:sea_lantern', Q = 'minecraft:quartz_block';
  var ground = gy - 1;
  for (var dx = -3; dx <= 3; dx++) for (var dz = -3; dz <= 3; dz++) put(level, cx + dx, ground, cz + dz, ES);
  ring(level, cx, ground + 1, cz, 3, P);
  // 四柱
  for (var i = 0; i < 4; i++) {
    var ax = (i % 2 === 0 ? -1 : 1) * 2, az = (i < 2 ? -1 : 1) * 2;
    column(level, cx + ax, gy, gy + 4, cz + az, P);
    put(level, cx + ax, gy + 5, cz + az, A);
  }
  // 顶盖（悬空圆盘）
  for (var dx2 = -5; dx2 <= 5; dx2++) for (var dz2 = -5; dz2 <= 5; dz2++) {
    if (Math.abs(dx2) === 5 || Math.abs(dz2) === 5) continue;
    put(level, cx + dx2, gy + 6, cz + dz2, Q);
  }
  // 中心紫水晶吊灯
  put(level, cx, gy + 6, cz, SL);
  put(level, cx, gy - 1, cz, A);
  console.info('[Starfall] 歇脚亭已建成 @ ' + dim + ' ' + cx + ',' + gy + ',' + cz);
}

// ==================== ① 晨曦花园城堡（绿谷） ====================
function buildGardenCastle(srv, dim, cx, gy, cz) {
  var level = srv.getLevel(dim);
  var S = 'minecraft:stone_bricks', MS = 'minecraft:mossy_stone_bricks', CS = 'minecraft:chiseled_stone_bricks';
  var O = 'minecraft:oak_log', P = 'minecraft:oak_planks', GW = 'minecraft:glass_pane';
  var T = 'minecraft:torch', FL = 'minecraft:sea_lantern';
  var W = 'minecraft:water', LIL = 'minecraft:lily_pad';
  var ground = gy - 1;
  for (var r = 8; r <= 22; r += 2) ring(level, cx, ground, cz, r, MS);
  ring(level, cx, ground, cz, 23, CS);
  var flowers = ['minecraft:poppy', 'minecraft:dandelion', 'minecraft:azure_bluet', 'minecraft:cornflower', 'minecraft:oxeye_daisy'];
  var fi = 0;
  for (var qx = -18; qx <= 18; qx += 4) for (var qz = -18; qz <= 18; qz += 4) {
    if (Math.abs(qx) < 7 && Math.abs(qz) < 7) continue;
    if (Math.abs(qx) === 18 || Math.abs(qz) === 18) continue;
    put(level, cx + qx, gy, cz + qz, flowers[fi++ % flowers.length]);
    put(level, cx + qx, ground, cz + qz, 'minecraft:grass_block');
  }
  for (var dx = -3; dx <= 3; dx++) for (var dz = -3; dz <= 3; dz++) {
    if (Math.abs(dx) === 3 || Math.abs(dz) === 3) { put(level, cx + dx, gy - 1, cz + dz, S); put(level, cx + dx, gy, cz + dz, W); }
  }
  put(level, cx, gy, cz, LIL); put(level, cx + 1, gy, cz, LIL);
  column(level, cx, gy, gy + 4, cz, S); put(level, cx, gy + 5, cz, FL);
  var wx0 = cx - 19, wx1 = cx + 19, wz0 = cz - 19, wz1 = cz + 19;
  for (var x = wx0; x <= wx1; x++) for (var z = wz0; z <= wz1; z++) {
    var edge = x === wx0 || x === wx1 || z === wz0 || z === wz1;
    if (!edge) continue;
    for (var h = 0; h < 5; h++) put(level, x, gy + h, z, h < 3 ? S : (h === 3 ? MS : CS));
  }
  for (var x = wx0; x <= wx1; x += 3) { put(level, x, gy + 5, wz0, CS); put(level, x, gy + 5, wz1, CS); }
  for (var z = wz0; z <= wz1; z += 3) { put(level, wx0, gy + 5, z, CS); put(level, wx1, gy + 5, z, CS); }
  towerBody(level, cx, gy, cz, 5, 18, S);
  fill(level, cx - 5, gy + 18, cz - 5, cx + 5, gy + 20, cz + 5, MS);
  for (var dx = -5; dx <= 5; dx += 1) { put(level, cx + dx, gy + 21, cz - 5, CS); put(level, cx + dx, gy + 21, cz + 5, CS); put(level, cx + dx, gy + 21, cz, CS); }
  for (var y = gy + 3; y <= gy + 15; y += 3) {
    put(level, cx - 5, y, cz, GW); put(level, cx + 5, y, cz, GW); put(level, cx, y, cz - 5, GW); put(level, cx, y, cz + 5, GW);
    put(level, cx - 5, y, cz - 5, T); put(level, cx + 5, y, cz + 5, T); put(level, cx - 5, y, cz + 5, FL); put(level, cx + 5, y, cz - 5, FL);
  }
  for (var i = 0; i < 4; i++) {
    var ax = (i % 2 === 0 ? -1 : 1) * 6, az = (i < 2 ? -1 : 1) * 6;
    towerBody(level, cx + ax, gy + 1, cz + az, 2, 11, S);
    put(level, cx + ax, gy + 12, cz + az, CS);
    column(level, cx + ax, gy + 13, gy + 15, cz + az, O);
    put(level, cx + ax, gy + 16, cz + az, FL);
  }
  for (var h = 0; h < 4; h++) { put(level, cx - 1, gy + h, cz + 5, CS); put(level, cx + 1, gy + h, cz + 5, CS); }
  put(level, cx, gy + 4, cz + 5, CS);
  for (var h = 1; h <= 5; h++) { put(level, cx - 2, gy + h, cz + 5, S); put(level, cx + 2, gy + h, cz + 5, S); }
  put(level, cx, gy + 4 + 3, cz + 5, CS);
  for (var dx = -2; dx <= 2; dx++) for (var h = 0; h < 2; h++) put(level, cx + dx, gy + h, cz + 6, P);
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
function buildRustLighthouse(srv, dim, cx, gy, cz) {
  var level = srv.getLevel(dim);
  var I = 'minecraft:iron_block', VI = 'minecraft:iron_bars', CB = 'minecraft:chiseled_stone_bricks';
  var B = 'minecraft:stone_bricks', RC = 'minecraft:red_concrete', DC = 'minecraft:dark_prismarine';
  var GS = 'minecraft:glowstone', SL = 'minecraft:sea_lantern', GL = 'minecraft:glass';
  var ground = gy - 1;
  for (var r = 4; r <= 10; r++) ring(level, cx, ground, cz, r, r === 10 ? CB : B);
  ring(level, cx, ground + 1, cz, 8, VI);
  var H = 34;
  for (var y = gy + 1; y < gy + H; y++)
    for (var dx = -3; dx <= 3; dx++) for (var dz = -3; dz <= 3; dz++) {
      var edge = Math.abs(dx) === 3 || Math.abs(dz) === 3;
      put(level, cx + dx, y, cz + dz, edge ? B : 'minecraft:air');
    }
  for (var y = gy + 3, k = 0; y < gy + H - 4; y += 3, k++) {
    var side = k % 4;
    if (side === 0) put(level, cx, y, cz - 3, GL);
    else if (side === 1) put(level, cx + 3, y, cz, GL);
    else if (side === 2) put(level, cx, y, cz + 3, GL);
    else put(level, cx - 3, y, cz, GL);
    put(level, cx + 3, y - 1, cz + 3, 'minecraft:torch');
    put(level, cx - 3, y - 1, cz - 3, GS);
  }
  fill(level, cx - 4, gy + H, cz - 4, cx + 4, gy + H + 1, cz + 4, I);
  hollowBox(level, cx - 3, gy + H + 2, cz - 3, cx + 3, gy + H + 5, cz + 3, GL, 'minecraft:air');
  put(level, cx, gy + H + 6, cz, SL);
  put(level, cx, gy + H + 7, cz, SL);
  for (var dx = -3; dx <= 3; dx++) { put(level, cx + dx, gy + H + 5, cz - 3, CB); put(level, cx + dx, gy + H + 5, cz + 3, CB); put(level, cx, gy + H + 5, cz + dx, CB); }
  for (var r = 4; r <= 7; r++) ring(level, cx, gy + H + 6, cz, r, r % 2 === 0 ? GS : VI);
  for (var r = 5; r <= 9; r += 2) { put(level, cx + r, ground + 1, cz, r % 2 === 0 ? DC : RC); }
  put(level, cx + 9, ground + 2, cz, VI);
  put(level, cx - 9, ground + 2, cz, VI);
  console.info('[Starfall] 锈岩灯塔已建成 @ ' + dim + ' ' + cx + ',' + gy + ',' + cz);
}

// ==================== ③ 霓虹空中阁楼（硅火） ====================
function buildNeonPavilion(srv, dim, cx, gy, cz) {
  var level = srv.getLevel(dim);
  var Q = 'minecraft:quartz_block', QB = 'minecraft:quartz_bricks', QP = 'minecraft:quartz_pillar';
  var A = 'minecraft:amethyst_block', AM = 'minecraft:amethyst_cluster';
  var NG = 'minecraft:magenta_stained_glass', NL = 'minecraft:sea_lantern', ST = 'minecraft:smooth_stone';
  var ground = gy - 1;
  var pad = 12;
  for (var dx = -pad; dx <= pad; dx++) for (var dz = -pad; dz <= pad; dz++) {
    put(level, cx + dx, ground, cz + dz, Q);
  }
  ring(level, cx, ground + 1, cz, pad, AM);
  var corn = [[-pad + 2, -pad + 2], [pad - 2, -pad + 2], [-pad + 2, pad - 2], [pad - 2, pad - 2]];
  var fly = gy + 18;
  for (var c = 0; c < corn.length; c++) {
    var px = cx + corn[c][0], pz = cz + corn[c][1];
    for (var y = gy + 1; y <= fly; y++) put(level, px, y, pz, QP);
    put(level, px, fly + 1, pz, NL);
  }
  // 悬空主阁（石英玻璃宫殿，18x18 x 高7）
  for (var x2 = cx - 9; x2 <= cx + 9; x2++) for (var z2 = cz - 9; z2 <= cz + 9; z2++) {
    put(level, x2, fly, z2, Q);
  }
  hollowBox(level, cx - 8, fly + 1, cz - 8, cx + 8, fly + 5, cz + 8, QB, 'minecraft:air');
  for (var y2 = fly + 2; y2 <= fly + 4; y2++) {
    put(level, cx - 8, y2, cz, NG); put(level, cx + 8, y2, cz, NG); put(level, cx, y2, cz - 8, NG); put(level, cx, y2, cz + 8, NG);
  }
  fill(level, cx - 9, fly + 6, cz - 9, cx + 9, fly + 7, cz + 9, ST);
  // 中心塔
  towerBody(level, cx, fly, cz, 2, 8, QP);
  put(level, cx, fly + 9, cz, NL);
  // 霓虹光带
  for (var ii = 0; ii < 4; ii++) {
    var ax2 = (ii % 2 === 0 ? -1 : 1) * 9, az2 = (ii < 2 ? -1 : 1) * 9;
    put(level, cx + ax2, fly + 6, cz, NL); put(level, cx, fly + 6, cz + az2, NL);
  }
  // 高空观景桥（东北-西南）
  for (var b = 0; b < 6; b++) put(level, cx - 14 + b, fly, cz - 14, QP);
  for (var b2 = 0; b2 < 6; b2++) put(level, cx + 14 - b2, fly, cz + 14, QP);
  console.info('[Starfall] 霓虹空中阁楼已建成 @ ' + dim + ' ' + cx + ',' + gy + ',' + cz);
}

// ==================== ④ 霄汉飞艇（苍穹） ====================
function buildSkyship(srv, dim, cx, gy, cz) {
  var level = srv.getLevel(dim);
  var W = 'minecraft:oak_planks', Y = 'minecraft:stripped_oak_log', G = 'minecraft:glass';
  var L = 'minecraft:lantern', I = 'minecraft:iron_block', B = 'minecraft:barrel';
  var ground = gy - 1;
  var fly = gy + 24;
  // 悬浮台
  for (var dx = -10; dx <= 10; dx++) for (var dz = -5; dz <= 5; dz++) put(level, cx + dx, fly, cz + dz, W);
  // 船体（长 14 宽 5）
  hollowBox(level, cx - 14, fly, cz - 2, cx + 14, fly + 5, cz + 2, W, 'minecraft:air');
  for (var y = fly + 1; y <= fly + 4; y++) { put(level, cx - 14, y, cz, G); put(level, cx + 14, y, cz, G); }
  put(level, cx + 14, fly + 4, cz, Y);
  // 后舱
  for (var dx2 = cx - 20; dx2 <= cx - 15; dx2++) for (var dz2 = cz - 2; dz2 <= cz + 2; dz2++) put(level, dx2, fly + 1, dz2, Y);
  // 帆（主桅）
  column(level, cx, fly + 1, fly + 12, cz, Y);
  for (var h = 2; h <= 11; h++) {
    put(level, cx, fly + h, cz - 3, W); put(level, cx, fly + h, cz + 3, W);
    put(level, cx, fly + h, cz - 2, W); put(level, cx, fly + h, cz + 2, W);
  }
  // 吊灯
  for (var d = -2; d <= 2; d++) { put(level, cx + d, fly - 3, cz, W); }
  put(level, cx, fly - 4, cz, L);
  // 甲板货桶与灯
  put(level, cx + 6, fly + 1, cz, B); put(level, cx + 8, fly + 1, cz, B);
  put(level, cx + 6, fly + 2, cz, L); put(level, cx - 6, fly + 2, cz, L);
  // 悬浮引擎
  put(level, cx + 20, fly, cz, I); put(level, cx - 20, fly, cz, I);
  put(level, cx + 20, fly + 1, cz, L); put(level, cx - 20, fly + 1, cz, L);
  console.info('[Starfall] 霄汉飞艇已建成 @ ' + dim + ' ' + cx + ',' + gy + ',' + cz);
}

// ==================== 星门与独石碑（保留） ====================
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

// waystone 传送石（放进地图即可注册路标，玩家可与其互动传送）
function buildWaystone(srv, dim, cx, y, cz) {
  var level = srv.getLevel(dim);
  for (var dx = -1; dx <= 1; dx++) for (var dz = -1; dz <= 1; dz++) put(level, cx + dx, y - 1, cz + dz, 'minecraft:chiseled_stone_bricks');
  put(level, cx, y, cz, 'waystones:waystone');
  console.info('[Starfall] 路标已立 @ ' + dim + ' ' + cx + ',' + y + ',' + cz);
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
      { id: 'valley', dim: 'minecraft:overworld', x: 0, z: -100, poi: 'castle', px: 60, pz: -150,
        stop: 'farm', stopDx: -40, stopDz: 80 },
      { id: 'rust', dim: 'starciv:rustfall', x: 200, z: 200, poi: 'lighthouse', px: 280, pz: 260,
        stop: 'outpost', stopDx: -60, stopDz: -70 },
      { id: 'silicon', dim: 'starciv:silicon', x: -300, z: 150, poi: 'pavilion', px: -360, pz: 210,
        stop: 'kiosk', stopDx: 80, stopDz: 60 },
      { id: 'stellaris', dim: 'starciv:stellaris', x: 120, z: -260, poi: 'skyship', px: 180, pz: -320,
        stop: 'rest', stopDx: -90, stopDz: -60 }
    ];
    var map = {};
    for (var i = 0; i < gates.length; i++) {
      var g = gates[i];
      if (!srv.getLevel(g.dim)) continue;
      var gy = findSurfaceY(srv, g.dim, g.x, g.z) + 1;
      buildGate(srv, g.dim, g.x, gy, g.z);
      if (g.dim === 'minecraft:overworld') {
        buildMonolith(srv, g.dim, g.x + 26, gy, g.z - 26);
        // 绿谷：出生点旁流动河流（起点在星门南侧）
        buildRiver(srv, g.dim, g.x - 20, gy + 6, g.z + 60, 48, 1);
      }
      var py = findSurfaceY(srv, g.dim, g.x + g.px, g.z + g.pz) + 1;
      if (g.poi === 'castle') buildGardenCastle(srv, g.dim, g.x + g.px, py, g.z + g.pz);
      if (g.poi === 'lighthouse') buildRustLighthouse(srv, g.dim, g.x + g.px, py, g.z + g.pz);
      if (g.poi === 'pavilion') buildNeonPavilion(srv, g.dim, g.x + g.px, py, g.z + g.pz);
      if (g.poi === 'skyship') buildSkyship(srv, g.dim, g.x + g.px, py, g.z + g.pz);
      // 驿站（分散在传送门周边，让地图上到处有建筑）
      var sy = findSurfaceY(srv, g.dim, g.x + g.stopDx, g.z + g.stopDz) + 1;
      if (g.stop === 'farm') buildFarmhouse(srv, g.dim, g.x + g.stopDx, sy, g.z + g.stopDz);
      if (g.stop === 'outpost') buildWastelandOutpost(srv, g.dim, g.x + g.stopDx, sy, g.z + g.stopDz);
      if (g.stop === 'kiosk') buildNeonKiosk(srv, g.dim, g.x + g.stopDx, sy, g.z + g.stopDz);
      if (g.stop === 'rest') buildSkyshipRest(srv, g.dim, g.x + g.stopDx, sy, g.z + g.stopDz);
      // waystone 传送石（地标门口 + 驿站）
      buildWaystone(srv, g.dim, g.x + g.px, py + 1, g.z + g.pz);
      buildWaystone(srv, g.dim, g.x + g.stopDx, sy + 1, g.z + g.stopDz);
      map[g.id] = { dim: g.dim, x: g.x, y: gy, z: g.z };
    }
    srv.persistentData.sc_gates_built = true;
    srv.persistentData.sc_gates = map;
    console.info('[Starfall] 全部景观已生成（地标+驿站+河流+路标）: ' + JSON.stringify(map));
    srv.runCommandSilent('tellraw @a {"text":"§6【文明编年史】§f星门点亮，五大地标与驿站拔地而起，绿谷有了第一条流动河流！","color":"gold"}');
  } catch (e) {
    console.error('[Starfall] 地标生成失败(不影响启动): ' + e);
  }
}
ServerEvents.loaded(buildStructures);