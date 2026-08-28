// =============================================================
// Starfall Chronicles — 世界生成：星门与上古遗迹（代码建结构）
// 使用 setblock 命令组合结构（兼容所有 KubeJS 版本）。
// 全世界加载一次；坐标写入 server.persistentData 供传送逻辑读取。
// =============================================================

const SC = global.SC;

// ---- 工具 ----------
function cmd(server, dim, str) {
  server.runCommandSilent('execute in ' + dim + ' run ' + str);
}
function setBlock(server, dim, x, y, z, block) {
  cmd(server, dim, 'setblock ' + x + ' ' + y + ' ' + z + ' ' + block);
}
function setLootChest(server, dim, x, y, z, lootTable) {
  setBlock(server, dim, x, y, z, 'minecraft:chest');
  cmd(server, dim, 'data merge block ' + x + ' ' + y + ' ' + z + ' {LootTable:"' + lootTable + '"}');
}
function getBlockId(level, x, y, z) {
  try { return String(level.getBlock(x, y, z).id); } catch (e) { return ''; }
}
// 从高处向下找第一个“脚下是实体方块/上方可站立”的 y
function findSurfaceY(server, dim, x, z) {
  const level = server.getLevel(dim);
  if (!level) return 64;
  for (let y = 200; y > -60; y--) {
    const b = getBlockId(level, x, y, z);
    if (b !== '' && b !== 'minecraft:air' && b !== 'minecraft:cave_air') {
      const above = getBlockId(level, x, y + 1, z);
      const above2 = getBlockId(level, x, y + 2, z);
      if ((above === '' || above === 'minecraft:air') && (above2 === '' || above2 === 'minecraft:air')) {
        return y + 1;
      }
    }
  }
  return 64;
}

// ---- 星门建造（环形门 + 铭文平台）----
function buildGate(server, dim, cx, y, cz) {
  const S = 'minecraft:obsidian';
  const G = 'minecraft:glowstone';
  const C = 'starciv:stargate_core';
  const B = 'minecraft:stone_bricks';
  const L = 'minecraft:sea_lantern';
  // 平台
  for (let dx = -2; dx <= 2; dx++) for (let dz = -2; dz <= 2; dz++) setBlock(server, dim, cx + dx, y - 1, cz + dz, B);
  // 双柱（高 5）
  for (let h = 0; h < 5; h++) {
    setBlock(server, dim, cx - 2, y + h, cz, S);
    setBlock(server, dim, cx + 2, y + h, cz, S);
    // 柱侧内嵌发光“云纹”
    if (h === 1 || h === 3) {
      setBlock(server, dim, cx - 2, y + h, cz + 1, G);
      setBlock(server, dim, cx + 2, y + h, cz + 1, G);
    }
  }
  // 楣梁
  for (let dx = -1; dx <= 1; dx++) setBlock(server, dim, cx + dx, y + 4, cz, S);
  // 顶部光芒（文明之息）
  setBlock(server, dim, cx, y + 5, cz, G);
  // 内环辉光（“门”的轮廓）
  for (let h = 1; h <= 3; h++) {
    setBlock(server, dim, cx - 1, y + h, cz, G);
    setBlock(server, dim, cx + 1, y + h, cz, G);
  }
  // 星门核心（交互点）
  setBlock(server, dim, cx, y + 1, cz, C);
  // 四角灯塔
  setBlock(server, dim, cx - 2, y, cz - 2, L);
  setBlock(server, dim, cx + 2, y, cz - 2, L);
  setBlock(server, dim, cx - 2, y, cz + 2, L);
  setBlock(server, dim, cx + 2, y, cz + 2, L);
  // 战利品箱（星门塔物资：种子/钥匙原料/日志）
  setLootChest(server, dim, cx - 3, y, cz, 'starciv:chests/stargate_tower');
  setLootChest(server, dim, cx + 3, y, cz, 'starciv:chests/stargate_tower');
}

// ---- 上古独石碑（绿谷星遗迹：上一文明留下的碑）----
function buildMonolith(server, dim, cx, y, cz) {
  const C = 'minecraft:chiseled_stone_bricks';
  const P = 'minecraft:stone_brick_wall';
  const G = 'minecraft:glowstone';
  const A = 'minecraft:amethyst_block';
  for (let dx = -1; dx <= 1; dx++) for (let dz = -1; dz <= 1; dz++) {
    for (let h = 0; h < 4; h++) setBlock(server, dim, cx + dx, y + h, cz + dz, C);
  }
  // 碑顶：紫晶 + 光芒
  setBlock(server, dim, cx, y + 4, cz, G);
  for (let dx = -1; dx <= 1; dx++) for (let dz = -1; dz <= 1; dz++) {
    if (dx === 0 && dz === 0) continue;
    setBlock(server, dim, cx + dx, y + 4, cz + dz, A);
  }
  // 底座台阶
  for (let dx = -2; dx <= 2; dx++) for (let dz = -2; dz <= 2; dz++) {
    if (Math.abs(dx) === 2 || Math.abs(dz) === 2) setBlock(server, dim, cx + dx, y - 1, cz + dz, P);
  }
  // 上古馈赠箱（独特的起源碑文与种子）
  setLootChest(server, dim, cx, y, cz + 2, 'starciv:chests/ancient_vault');
}

// ---- 主入口 ----------
ServerEvents.loaded(event => {
  try {
  const server = event.server;
  if (!server || server.persistentData.sc_gates_built) return;
  server.persistentData.sc_gates_built = true;

  const overworld = server.getLevel(SC.dims.valley);
  let sx = 0, sz = 0;
  try {
    const spawn = overworld.getSharedSpawnPos();
    sx = spawn.x; sz = spawn.z;
  } catch (e) { /* 保留 0,0 回退 */ }

  const gates = {};
  const valleyGateX = sx + SC.gate_offsets.valley.dx;
  const valleyGateZ = sz + SC.gate_offsets.valley.dz;
  const monoX = sx + SC.gate_offsets.monolith.dx;
  const monoZ = sz + SC.gate_offsets.monolith.dz;

  // 绿谷星星门 + 独石碑
  const vy = findSurfaceY(server, SC.dims.valley, valleyGateX, valleyGateZ) + 1;
  buildGate(server, SC.dims.valley, valleyGateX, vy, valleyGateZ);
  gates.valley = { dim: SC.dims.valley, x: valleyGateX, y: vy, z: valleyGateZ };
  const my = findSurfaceY(server, SC.dims.valley, monoX, monoZ) + 1;
  buildMonolith(server, SC.dims.valley, monoX, my, monoZ);
  gates.monolith = { dim: SC.dims.valley, x: monoX, y: my, z: monoZ };

  // 铁锈/硅火/苍穹 三颗星球的星门（各星球坐标原点附近）
  const planetGates = [
    { id: 'rust',      dim: SC.dims.rust,       x: 0,   z: 0 },
    { id: 'silicon',   dim: SC.dims.silicon,    x: 64,  z: -64 },
    { id: 'stellaris', dim: SC.dims.stellaris,  x: -128, z: 128 }
  ];
  for (const g of planetGates) {
    const gy = findSurfaceY(server, g.dim, g.x, g.z) + 1;
    buildGate(server, g.dim, g.x, gy, g.z);
    gates[g.id] = { dim: g.dim, x: g.x, y: gy, z: g.z };
  }
  server.persistentData.sc_gates = gates;

  console.info('[Starfall] 星门已生成: ' + JSON.stringify(gates));
  server.runCommandSilent('tellraw @a {"text":"§6【文明编年史】§f四座星门已在各文明世界点亮。","color":"gold"}');
  } catch (e) {
    console.error('[Starfall] 星门生成失败(不影响启动): ' + e);
  }
});