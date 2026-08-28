// =============================================================
// Starfall Chronicles — 苍穹星（星际文明）配方
// 终局：跃迁核心 → 跃迁引擎 → 信标/鞘翅（终局内容）
// =============================================================

ServerEvents.recipes(event => {
  const { shaped, shapeless } = event;

  // ---- 跃迁核心：量子核心 + Ad Astra 引擎框架/钢板 ----
  // 跨文明核心循环：硅火星的 AI 核心，在这里变成曲率引擎的心脏。
  shaped('1x starciv:warp_core', [
    'FPF',
    'PQP',
    'FPF'
  ], {
    F: 'ad_astra:engine_frame',
    P: 'ad_astra:steel_plate',
    Q: 'starciv:quantum_core'
  }).stage('interstellar');

  // ---- 跃迁引擎：Core + 下界合金 + 烈焰棒（终局引擎）----
  shaped('1x starciv:warp_engine', [
    'NBN',
    'BWB',
    'NBN'
  ], {
    N: 'minecraft:netherite_ingot',
    B: 'minecraft:blaze_rod',
    W: 'starciv:warp_core'
  }).stage('interstellar');

  // ---- 终局装备：鞘翅（苍穹星自由翱翔）----
  shaped('1x minecraft:elytra', [
    'PW',
    'PP'
  ], {
    P: 'minecraft:phantom_membrane',
    W: 'starciv:warp_core'
  }).stage('interstellar');

  // ---- 终局信标：文明灯塔（原版不可合成，这里作为文明之巅象征）----
  shaped('1x minecraft:beacon', [
    'GGG',
    'GWG',
    'OOO'
  ], {
    G: 'minecraft:glass',
    W: 'starciv:warp_core',
    O: 'minecraft:obsidian'
  }).stage('interstellar');

  // 提示：Ad Astra 的火箭/空间站是本星球舞台；L_Ender's Cataclysm
  // 的灾厄 Boss 是终局史诗遭遇。
});