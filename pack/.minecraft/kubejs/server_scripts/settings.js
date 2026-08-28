// =============================================================
// Starfall Chronicles — 全局设置（唯一事实源）
// 通过 global.SC 供所有 server 脚本引用。
// =============================================================

global.SC = {
  // 四星球维度（绿谷星 = 原版主世界）
  dims: {
    valley:   'minecraft:overworld',
    rust:     'starciv:rustfall',
    silicon:  'starciv:silicon',
    stellaris: 'starciv:stellaris'
  },
  // 文明阶段（KubeJS stages，控制配方解锁 + 传送权限）
  stages: {
    agriculture: 'agricultural',
    industry:    'industrial',
    information: 'information',
    interstellar: 'interstellar'
  },
  // 星门传送规则表：
  // from -> to, 所需阶段, 消耗物品（null 表示免费）, 目标门坐标（建造时写入 persistentData）
  warp_rules: {
    valley:   { to: 'rust',     need_stage: null,            consume: null },
    rust:     { to: 'silicon',  need_stage: 'industrial',    consume: 'starciv:biofuel_canister' },
    silicon:  { to: 'stellaris', need_stage: 'information',  consume: null },
    stellaris:{ to: 'valley',   need_stage: null,            consume: null }
  },
  // 首航铁律：从绿谷星出发需要星门钥匙（文明启蒙仪式）
  first_journey_requires_key: true,
  // 星门建造（世界首次加载时动态定位，坐标写入 persistentData）
  gate_offsets: {
    valley:   { dx: 60,  dz: 0 },
    monolith: { dx: -140, dz: -120 },
    valley_orchard: { dx: 48, dz: 40 }
  },
  // 上古遗迹（绿谷星独石碑）再访冷却（秒）
  monolith_cooldown: 1800,
  // 传送冷却（秒）
  warp_cooldown: 5
};

console.info('[Starfall] 设置加载完成: ' + JSON.stringify(global.SC.dims));