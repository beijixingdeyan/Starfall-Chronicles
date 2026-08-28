// =============================================================
// Starfall Chronicles — 世界生成：星门、上古遗迹与星球特色建筑
// 使用 setblock 命令组合结构（兼容所有 KubeJS 版本）。
// 规则：
//  1) 星球维度未就绪（数据包未装载）时延后重试，绝不误置位；
//  2) 生成成功后才写入 srv.persistentData；
//  3) 所有结构偏星球环境（绿谷=农耕、铁锈=工业废墟、硅火=霓虹塔、苍穹=上古神庙）。
// =============================================================

// ---- 工具 ----------
function cmd(srv, dim, str) {
  srv.runCommandSilent('execute in ' + dim + ' run ' + str);
}
function setBlock(srv, dim, x, y, z, block) {
  cmd(srv, dim, 'setblock ' + x + ' ' + y + ' ' + z + ' ' + block);
}
function setLootChest(srv, dim, x, y, z, lootTable) {
  setBlock(srv, dim, x, y, z, 'minecraft:chest');
  cmd(srv, dim, 'data merge block ' + x + ' ' + y + ' ' + z + ' {LootTable:"' + lootTable + '"}');
}
function getBlockId(level, x, y, z) {
  try { return String(level.getBlock(x, y, z).id); } catch (e) { return ''; }
}
// 从高处向下找第一个“脚下是实体方块/上方可站立”的 y
function findSurfaceY(srv, dim, x, z) {
  var level = srv.getLevel(dim);
  if (!level) return 64;
  for (var y = 200; y > -60; y--) {
    var b = getBlockId(level, x, y, z);
    if (b !== '' && b !== 'minecraft:air' && b !== 'minecraft:cave_air') {
      var above = getBlockId(level, x, y + 1, z);
      var above2 = getBlockId(level, x, y + 2, z);
      if ((above === '' || above === 'minecraft:air') && (above2 === '' || above2 === 'minecraft:air')) {
        return y + 1;
      }
    }
  }
  return 64;
}

// ---- 星门建造（环形门 + 铭文平台）----
function buildGate(srv, dim, cx, y, cz) {
  var S = 'minecraft:obsidian';
  var G = 'minecraft:glowstone';
  var C = 'starciv:stargate_core';
  var B = 'minecraft:stone_bricks';
  var L = 'minecraft:sea_lantern';
  for (var dx = -2; dx <= 2; dx++) for (var dz = -2; dz <= 2; dz++) setBlock(srv, dim, cx + dx, y - 1, cz + dz, B);
  for (var h = 0; h < 5; h++) {
    setBlock(srv, dim, cx - 2, y + h, cz, S);
    setBlock(srv, dim, cx + 2, y + h, cz, S);
    if (h === 1 || h === 3) {
      setBlock(srv, dim, cx - 2, y + h, cz + 1, G);
      setBlock(srv, dim, cx + 2, y + h, cz + 1, G);
    }
  }
  for (var dx = -1; dx <= 1; dx++) setBlock(srv, dim, cx + dx, y + 4, cz, S);
  setBlock(srv, dim, cx, y + 5, cz, G);
  for (var h = 1; h <= 3; h++) {
    setBlock(srv, dim, cx - 1, y + h, cz, G);
    setBlock(srv, dim, cx + 1, y + h, cz, G);
  }
  setBlock(srv, dim, cx, y + 1, cz, C);
  setBlock(srv, dim, cx - 2, y, cz - 2, L);
  setBlock(srv, dim, cx + 2, y, cz - 2, L);
  setBlock(srv, dim, cx - 2, y, cz + 2, L);
  setBlock(srv, dim, cx + 2, y, cz + 2, L);
  setLootChest(srv, dim, cx - 3, y, cz, 'starciv:chests/stargate_tower');
  setLootChest(srv, dim, cx + 3, y, cz, 'starciv:chests/stargate_tower');
}

// ---- 上古独石碑（绿谷星遗迹）----
function buildMonolith(srv, dim, cx, y, cz) {
  var C = 'minecraft:chiseled_stone_bricks';
  var P = 'minecraft:stone_brick_wall';
  var G = 'minecraft:glowstone';
  var A = 'minecraft:amethyst_block';
  for (var dx = -1; dx <= 1; dx++) for (var dz = -1; dz <= 1; dz++) {
    for (var h = 0; h < 4; h++) setBlock(srv, dim, cx + dx, y + h, cz + dz, C);
  }
  setBlock(srv, dim, cx, y + 4, cz, G);
  for (var dx = -1; dx <= 1; dx++) for (var dz = -1; dz <= 1; dz++) {
    if (dx === 0 && dz === 0) continue;
    setBlock(srv, dim, cx + dx, y + 4, cz + dz, A);
  }
  for (var dx = -2; dx <= 2; dx++) for (var dz = -2; dz <= 2; dz++) {
    if (Math.abs(dx) === 2 || Math.abs(dz) === 2) setBlock(srv, dim, cx + dx, y - 1, cz + dz, P);
  }
  setLootChest(srv, dim, cx, y, cz + 2, 'starciv:chests/ancient_vault');
}

// ---- 绿谷：果园祭坛（农耕文明的田园小品）----
function buildValleyOrchard(srv, dim, cx, y, cz) {
  var F = 'minecraft:oak_fence';
  for (var dx = 0; dx < 5; dx++) {
    setBlock(srv, dim, cx + dx, y, cz, 'minecraft:farmland[moisture=7]');
    setBlock(srv, dim, cx + dx, y, cz + 2, 'minecraft:farmland[moisture=7]');
  }
  for (var dx = 0; dx < 5; dx++) {
    setBlock(srv, dim, cx + dx, y + 1, cz, 'minecraft:wheat[age=7]');
    setBlock(srv, dim, cx + dx, y + 1, cz + 2, 'minecraft:wheat[age=7]');
  }
  setBlock(srv, dim, cx, y, cz + 1, 'minecraft:water');
  setBlock(srv, dim, cx + 4, y, cz + 1, 'minecraft:water');
  setBlock(srv, dim, cx + 2, y, cz + 1, 'minecraft:campfire[lit=true]');
  setBlock(srv, dim, cx - 1, y, cz, F);
  setBlock(srv, dim, cx + 5, y, cz, F);
  setBlock(srv, dim, cx - 1, y, cz + 2, F);
  setBlock(srv, dim, cx + 5, y, cz + 2, F);
  setLootChest(srv, dim, cx + 2, y, cz + 3, 'minecraft:chests/village/village_plains_house');
}

// ---- 铁锈：锈蚀工厂遗迹（工业文明的地标）----
function buildRustFactory(srv, dim, cx, y, cz) {
  var W = 'minecraft:cracked_stone_bricks';
  var B = 'minecraft:iron_bars';
  // 主体围墙
  for (var dx = -2; dx <= 2; dx++) {
    setBlock(srv, dim, cx + dx, y, cz - 2, W);
    setBlock(srv, dim, cx + dx, y, cz + 2, W);
  }
  for (var dz = -1; dz <= 1; dz++) {
    setBlock(srv, dim, cx - 2, y, cz + dz, W);
    setBlock(srv, dim, cx + 2, y, cz + dz, W);
  }
  // 高炉与料斗（车间核心）
  setBlock(srv, dim, cx, y + 1, cz, 'minecraft:blast_furnace[facing=north]');
  setBlock(srv, dim, cx, y + 2, cz, 'minecraft:hopper[facing=down]');
  setBlock(srv, dim, cx, y + 3, cz, 'minecraft:iron_block');
  setBlock(srv, dim, cx - 1, y + 1, cz, 'minecraft:lantern[hanging=false]');
  setBlock(srv, dim, cx + 1, y + 1, cz, 'minecraft:lantern[hanging=false]');
  // 铁栅窗
  for (var h = 1; h <= 3; h++) {
    setBlock(srv, dim, cx - 2, y + h, cz, B);
    setBlock(srv, dim, cx + 2, y + h, cz, B);
  }
  setLootChest(srv, dim, cx + 2, y + 1, cz + 2, 'starciv:chests/stargate_tower');
}

// ---- 硅火：霓虹数据塔（信息文明的都市剪影）----
function buildSiliconTower(srv, dim, cx, y, cz) {
  var Q = 'minecraft:chiseled_quartz_block';
  var A = 'minecraft:amethyst_block';
  // 塔身
  for (var h = 0; h < 6; h++) {
    setBlock(srv, dim, cx, y + h, cz, Q);
    if (h % 2 === 0) {
      setBlock(srv, dim, cx + 1, y + h, cz, A);
      setBlock(srv, dim, cx - 1, y + h, cz, A);
      setBlock(srv, dim, cx, y + h, cz + 1, A);
      setBlock(srv, dim, cx, y + h, cz - 1, A);
    }
  }
  // 顶层光球 + 信号灯
  setBlock(srv, dim, cx, y + 6, cz, 'minecraft:sea_lantern');
  setBlock(srv, dim, cx, y + 7, cz, 'minecraft:redstone_lamp[lit=true]');
  setBlock(srv, dim, cx + 2, y, cz + 2, 'minecraft:lantern[hanging=true]');
  setBlock(srv, dim, cx - 2, y, cz - 2, 'minecraft:lantern[hanging=true]');
  setLootChest(srv, dim, cx + 1, y + 1, cz + 1, 'minecraft:chests/ancient_city');
}

// ---- 苍穹：上古神庙（星际文明的精神原点）----
function buildStellarTemple(srv, dim, cx, y, cz) {
  var P = 'minecraft:purpur_block';
  var PL = 'minecraft:purpur_pillar';
  var C = 'minecraft:chiseled_stone_bricks';
  // 基座
  for (var dx = -2; dx <= 2; dx++) for (var dz = -2; dz <= 2; dz++) {
    setBlock(srv, dim, cx + dx, y - 1, cz + dz, C);
  }
  // 四柱
  for (const [px, pz] of [[-2, -2], [2, -2], [-2, 2], [2, 2]]) {
    for (var h = 0; h < 5; h++) setBlock(srv, dim, cx + px, y + h, cz + pz, PL);
    setBlock(srv, dim, cx + px, y + 5, cz + pz, 'minecraft:end_rod');
  }
  // 祭坛
  setBlock(srv, dim, cx, y, cz, 'minecraft:obsidian');
  setBlock(srv, dim, cx, y + 1, cz, 'minecraft:emerald_block');
  setBlock(srv, dim, cx, y + 2, cz, 'minecraft:sea_lantern');
  for (var dx = -1; dx <= 1; dx++) for (var dz = -1; dz <= 1; dz++) {
    if (dx === 0 && dz === 0) continue;
    setBlock(srv, dim, cx + dx, y, cz + dz, P);
  }
  setLootChest(srv, dim, cx + 2, y, cz - 2, 'minecraft:chests/end_city_treasure');
}

// ---- 主入口 ----------
// 注意：ServerEvents.loaded 单进程内可能触发多次，Rhino 箭头函数里的 const
// 跨次调用可能报 "redeclaration"；用具名函数注册，每次调用都是全新激活域。
function buildStructures(event) {
  try {
    var srv = event.server;
    if (!srv) return;

    // 星球维度就绪检查（数据包未装载时延后，不置位，下次再试）
    if (!srv.getLevel(global.SC.dims.valley) || !srv.getLevel(global.SC.dims.rust)) {
      console.info('[Starfall] 星门生成延后：星球维度尚未就绪（数据包将在下次启动装载后生效）');
      return;
    }
    if (srv.persistentData.sc_gates_built) return;

    var overworld = srv.getLevel(global.SC.dims.valley);
    var sx = 0, sz = 0;
    try {
      var spawn = overworld.getSharedSpawnPos();
      sx = spawn.x; sz = spawn.z;
    } catch (e) { /* 保留 0,0 回退 */ }

    var gates = {};
    var valleyGateX = sx + global.SC.gate_offsets.valley.dx;
    var valleyGateZ = sz + global.SC.gate_offsets.valley.dz;
    var monoX = sx + global.SC.gate_offsets.monolith.dx;
    var monoZ = sz + global.SC.gate_offsets.monolith.dz;

    // 绿谷星星门 + 独石碑 + 果园祭坛
    var vy = findSurfaceY(srv, global.SC.dims.valley, valleyGateX, valleyGateZ) + 1;
    buildGate(srv, global.SC.dims.valley, valleyGateX, vy, valleyGateZ);
    gates.valley = { dim: global.SC.dims.valley, x: valleyGateX, y: vy, z: valleyGateZ };
    var my = findSurfaceY(srv, global.SC.dims.valley, monoX, monoZ) + 1;
    buildMonolith(srv, global.SC.dims.valley, monoX, my, monoZ);
    gates.monolith = { dim: global.SC.dims.valley, x: monoX, y: my, z: monoZ };
    var oy = findSurfaceY(srv, global.SC.dims.valley, valleyGateX + global.SC.gate_offsets.valley_orchard.dx, valleyGateZ + global.SC.gate_offsets.valley_orchard.dz) + 1;
    buildValleyOrchard(srv, global.SC.dims.valley, valleyGateX + global.SC.gate_offsets.valley_orchard.dx, oy, valleyGateZ + global.SC.gate_offsets.valley_orchard.dz);

    // 铁锈/硅火/苍穹 三颗星球的星门 + 星球特色建筑
    var planetGates = [
      { id: 'rust',      dim: global.SC.dims.rust,       x: 0,    z: 0,    poi: 'factory',  px: 24,  pz: 0 },
      { id: 'silicon',   dim: global.SC.dims.silicon,    x: 64,   z: -64,  poi: 'tower',    px: 0,   pz: -40 },
      { id: 'stellaris', dim: global.SC.dims.stellaris,  x: -128, z: 128,  poi: 'temple',   px: 40,  pz: -40 }
    ];
    for (var g of planetGates) {
      var gy = findSurfaceY(srv, g.dim, g.x, g.z) + 1;
      buildGate(srv, g.dim, g.x, gy, g.z);
      gates[g.id] = { dim: g.dim, x: g.x, y: gy, z: g.z };
      var py = findSurfaceY(srv, g.dim, g.x + g.px, g.z + g.pz) + 1;
      if (g.poi === 'factory') buildRustFactory(srv, g.dim, g.x + g.px, py, g.z + g.pz);
      if (g.poi === 'tower')   buildSiliconTower(srv, g.dim, g.x + g.px, py, g.z + g.pz);
      if (g.poi === 'temple')  buildStellarTemple(srv, g.dim, g.x + g.px, py, g.z + g.pz);
    }

    // 全部成功后再置位（下一次启动不再重建）
    srv.persistentData.sc_gates_built = true;
    srv.persistentData.sc_gates = gates;

    console.info('[Starfall] 星门与星球建筑已生成: ' + JSON.stringify(gates));
    srv.runCommandSilent('tellraw @a {"text":"§6【文明编年史】§f四座星门与四座星球地标已点亮。","color":"gold"}');
  } catch (e) {
    console.error('[Starfall] 星门生成失败(不影响启动): ' + e);
  }
}
ServerEvents.loaded(buildStructures);