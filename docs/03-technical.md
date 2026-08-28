# 03 · 技术实现（Phase 2）

## 1. 脚本层：KubeJS 6（主）+ CraftTweaker（备）

所有自定义逻辑在 `pack/.minecraft/kubejs/`，文件即最终成品，可直接被 KubeJS 6 加载。

### 1.1 配方修改：强制跨文明资源流通

```js
// 绿谷星的上古之种 → 铁锈星的生物燃料（Create 加热混合）
event.recipes.create.mixing(
  Item.of('starciv:biofuel_canister', 1),
  ['2x starciv:ancient_seed', 'minecraft:coal']
).heated().stage('industrial');

// 工业效率升级：Mekanism 富集机 1 种子 → 4 精粹
event.recipes.mekanism.enriching('4x starciv:civ_essence', 'starciv:ancient_seed')
  .stage('industrial');
```

### 1.2 按文明阶段锁定科技（任务前置）

```js
// 精密零件（铁锈星产物）→ 量子核心（硅火星产品）
shapeless('1x starciv:quantum_core', [
  '2x starciv:precision_parts',
  'ae2:calculation_processor',
  'minecraft:diamond',
  'minecraft:redstone_block'
]).stage('information');
```

`stage()` 以 KubeJS 阶段系统实现；阶段由 `server_scripts/stages.js` 在玩家**抵达对应星球**时自动授予
（tick 轮询维度，不依赖任何版本敏感事件）。JEI 中未达阶段配方直接不可见——玩家必须按主线走。

### 1.3 自定义事件

```js
// 首次进入：史书 + 指引
PlayerEvents.loggedIn(event => { /* 见 events/welcome.js */ });

// 星门跃迁：右键星门核心
BlockEvents.rightClicked('starciv:stargate_core', event => { /* 见 worldgen/stargate_interact.js */ });

// 服务器世界第一次加载：代码生成四座星门 + 独石碑（setblock 命令，跨版本稳定）
ServerEvents.loaded(event => { /* 见 worldgen/structures.js */ });
```

### 1.4 自定义物品/方块注册（startup_scripts/registry.js）

`starciv:ancient_seed`、`civ_essence`、`stellar_key`、`biofuel_canister`、`data_slivers`、
`precision_parts`、`quantum_core`、`warp_core`、`warp_engine` 与方块 `stargate_core`。
纹理由 `scripts/build_textures.ps1` 程序化生成（无第三方依赖）。

## 2. 数据包：自定义维度/群系/进度/战利品

数据包位于 `pack/.minecraft/datapacks/starciv_dp/`（pack_format 15）。

### 2.1 维度（三颗新星球）

| 维度 | 类型 | 生成器 | 生物群系 |
|------|------|--------|---------|
| `starciv:rustfall` | `starciv:rustfall` | noise(overworld) | `starciv:rust_wastes`（橙雾锈地） |
| `starciv:silicon` | `starciv:silicon` | noise(overworld) | `starciv:silicon_city`（霓虹夜城） |
| `starciv:stellaris` | `starciv:stellaris` | noise(overworld) | `starciv:stellar_plains`（星云原野） |

另附三个备选群系（`rust_blighted_forest`、`silicon_arcology`、`stellar_crystal_badlands`），
在维度 JSON 的 `biome_source.biomes` 中替换即可启用（已通过 schema 校验，属设计好的“换皮”开关）。

### 2.2 自定义世界生成

- 6 个生物群系 JSON（天空/雾/水体/植被配色 + 刷怪表 + 特征列表）。
- 3 个自定义 configured/placed feature：`glowstone_cluster`（锈地矿灯）、
  `neon_lamp`/`neon_patch`（霓虹点阵）、`amethyst_cluster`（紫晶晶体）。
- 星门/独石碑等**结构**由 KubeJS 用 `setblock` 程序化生成（免 NBT 模板，跨版本稳健）。

### 2.3 进度树（Advancement Tree，data/starciv/advancements/）

科技树式树状进度，共 27 节点：

```
starciv:root（文明编年史）
└─ agriculture: start → first_fruit → artisan → explore_ruin → stellar_key
                 └→ apiarist → trader
   └─ industry:  arrival → mechanic → fuel → precision →（跃迁）
                 └→ smelter → rail        └→ pipes（平行分支）
      └─ information: arrival → code → chips → core →（跃迁）
                    └→ network → data
         └─ interstellar: arrival → fabricator → drive → engine（奖励：失落科技）→ hidden/lost_tech
                       └→ contact（击杀灾厄 Boss）
```

- 到达类进度用 `minecraft:changed_dimension` 触发器（纯数据，稳定）。
- 独石碑拜访用 `minecraft:impossible` + KubeJS 命令授予（`advancement grant`）。
- 跃迁引擎节点带 reward function `starciv:quest/reveal_lost_tech`：揭示终局剧情并授予隐藏进度。

### 2.4 战利品表与函数

- `stargate_tower`（星门塔宝箱：古代种子/钥匙原料/《星门日志》📖）。
- `ancient_vault`（独石碑馈赠：种子/紫水晶/《起源碑文》📖）。
- functions：`arrive/*`（四星球抵达补给与叙事）、`quest/reveal_lost_tech`、`quest/seed_gift`（调试）。

## 3. 性能优化方案

### 3.1 优化模组（11 个）：见 docs/02 分类 A。

### 3.2 JVM 参数（6-8GB 标准；12GB 极致改为 `-Xmx12G`）

```
-Xmx6G -Xms2G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200
-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:G1NewSizePercent=30
-XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20
-XX:G1MixedGCCountTarget=4 -XX:SurvivorRatio=32 -XX:+AlwaysPreTouch
-Dfml.ignorePatchDiscrepancies=true -Dfml.ignoreInvalidMinecraftCertificates=true
```

已写入 `pack/instance.cfg`（Prism）与 `launch/jvm-args.txt`。

### 3.3 配置建议

- **Embeddium**：渲染距离 10-12；开启 “Use Fog”；关闭景深/动态模糊。
- **ModernFix**：默认即可；若内存紧张开启 “Dynamic resources”。
- **Serene Seasons**：季节长度保持默认；关闭“季节风暴”避免干扰开局（可选）。
- **Pollution of the Realms**：开局污染阈值保持默认；多人可调 2 倍净化速率。
- **Jade/Toast Control**：按需隐藏提示，减少刷屏。

### 3.4 崩溃率 ≤ 1次/4小时的保障

现代核心（Embeddium/ModernFix/FerriteCore/MemoryLeakFix）+ 冲突规避（见 02 末尾）+
Spark 周期性分析（`/spark heapsummary` 定位泄漏）+ 存档迁移工具（见 docs/07）。

## 4. 如何启用数据包（必须步骤）

> Minecraft **不会**自动加载 `.minecraft/datapacks`（连社区都为此写过“global-datapacks”模组），
> 因此请在**创建世界**时启用：

1. 创建世界 → 「更多」→ 「数据包」。
2. 「打开数据包文件夹」→ 把 `pack/.minecraft/datapacks/starciv_dp/` 整个文件夹拖入。
3. 回到游戏，将 starciv_dp 从“可用”移到“已选择” → 完成创建。

- **已有世界**：把 `starciv_dp` 复制到 `saves/<世界>/datapacks/` → 游戏内 `/reload`。
- **服务器**：放进 `<服务端>/world/datapacks/` → `/reload`（需 op）。

启用后检查：`/datapack list` 应显示 `file/starciv_dp`；进服/回主世界传送 `/execute in starciv:rustfall run tp @s 0 100 0` 验证维度。
资源包（语言/物品名）在「选项 → 资源包」中启用 `starciv_resources`。

## 配方实现说明（2026-08 修订）

- **跨模组/带 NBT/机器配方一律用数据包 JSON**（data/starciv/recipes/）：civ_essence_from_seed、stellar_key、iofuel_canister（含营火变体）、enrich_seed（mekanism:enriching）、mill_amethyst（create:milling）、crush_amethyst（mekanism:crushing）。原因是本 KubeJS 构建对 create:mixing/milling、mekanism:enriching/crushing 的构造器签名不兼容（“Constructor ... arguments not found”），且带 NBT 输出的数据包配方在部分 Forge 构建会 SNBT 解析报错——**KubeJS 侧只保留已证明可用的隐式 shaped/shapeless**。
- **手册配方（指南书 NBT 输出）用 KubeJS Item.of('patchouli:guide_book', '{patchouli:book:"starciv:handbook"}') 对象输出**，NBT 由引擎原生构造，不经字符串解析。
- **KubeJS 脚本作用域纪律**：脚本共享同一顶层作用域，禁止在多个文件顶层声明同名 const（会 edeclaration of const）；事件回调内尽量用 ar（ServerEvents.loaded 等事件可能多次触发，箭头函数里 const 二次触发会报 redeclaration）。