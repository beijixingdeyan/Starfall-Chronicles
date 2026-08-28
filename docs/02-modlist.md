# 02 · 完整模组清单（Phase 2）

> MC **1.20.1 · Forge 47.4.53**，共 **78 个模组**（74 默认安装 + 1 可选 Oculus + 3 CurseForge 手动），
> 全部经 Modrinth API 校验存在 1.20.1 + Forge 版本（版本号为本仓库 2026 快照，脚本会装“最新匹配版”）。
> **禁止无脑堆砌**：每个模组都有明确叙事目的，缺失任一 required 模组会让对应星球玩法失效。
> 安装：`pwsh scripts/install_mods.ps1`（或 `bash scripts/install_mods.sh`）。单一数据源：`scripts/mods.json`。

## 分类总览

| 分类 | 数量 | 一句话 |
|------|------|--------|
| 核心优化 optimization | 11 | 启动 <5 分钟、6-8GB 流畅、4 小时不崩 |
| 界面辅助 ui | 10 | 配方可视化、地图、背包、传送 |
| 绿谷星 agriculture | 12 | 农耕、四季、酿造、养蜂、村落 |
| 铁锈星 industry | 9 | 机械、重工业、物流、污染 |
| 硅火星 information | 8 | 存储网络、编程、逻辑、赛博建材 |
| 苍穹星 interstellar | 3 | 火箭、自动化接口、史诗 Boss |
| 冒险世界 adventure_worldgen | 8 | 地表多样、遗迹、地牢、城镇 |
| 魔法分支 magic_branch | 3 | Botania / Ars Nouveau / Patchouli |
| 库 libraries | 11 | 脚本层与前置库 |
| 可选 graphics | 1 | Oculus（光影） |
| CurseForge 独有 | 3 | Flux Networks / MineColonies / LazyDFU 兜底 |

## A. 核心优化（11）

| 模组 | 版本快照 | 为什么需要 |
|------|---------|-----------|
| Embeddium | 0.3.31+mc1.20.1 | 渲染优化（Sodium for Forge）：6-8GB 内存 60fps+ |
| ModernFix | 5.27.77+mc1.20.1 | 动态资源加载/DFU 降级：**主菜单 <5 分钟**的关键 |
| FerriteCore | 6.0.1 | 内存-30%，12GB 极致画质 |
| LazyDFU | 0.1.3 | 数据修复懒加载（若 Modrinth 无 1.20.1 则用 CurseForge） |
| Spark | 1.10.53-forge | 性能分析：定位卡顿与泄漏 |
| EntityCulling | 1.10.5 | 视野外实体不渲染（硅火星巨型城市不掉帧） |
| MemoryLeakFix | v1.1.5 | 长时间挂机内存稳定 |
| FastSuite | 5.1.2 | 配方计算聚合加速 |
| FastWorkbench | 8.0.4 | 工作台配方缓存 |
| FastFurnace | 8.0.2 | 熔炉配方缓存（冶炼链） |
| Saturn | mc1.20.1-0.1.3 | 无成本优化补丁 |

## B. 界面与冒险辅助（10）

JEI 15.49 · Jade 11.13 · Xaero's Minimap 26.4.2 · Xaero's World Map 1.45.0 · AppleSkin 2.5.1 ·
Controlling 12.0.2 · Mouse Tweaks 2.25.1 · Inventory Profiles Next 1.10.20 · Sophisticated Backpacks 3.24.67 · Waystones 14.1.20

作用：配方可视化（JEI 是跨文明链“谁能合、缺什么”的核心）、指向提示、四星球导航、一键整理、背包扩容、星球内传送石碑。

## C. 绿谷星 · 农耕文明（12）

Farmer's Delight 1.3.3 · Brewin' and Chewin' 3.2.1 · Serene Seasons 9.1.0.3 · Alex's Mobs 1.22.9 ·
Naturalist 5.0pre4 · Productive Bees 12.6.0 · Quark 4.0-462 · Supplementaries 3.1.43 · Botany Pots 13.0.43 ·
Decorative Blocks 4.1.3 · Easy Villagers 1.1.39 · **MineColonies（CF）**

作用详见 docs/01，一句话：**让“种田”成为足够深的文明起点**（四季、烹饪、酿造、养蜂、村民、殖民地）。

## D. 铁锈星 · 工业文明（9）

Create 6.0.8 · Create Addition 1.3.x · Create: Steam 'n' Rails 1.7.3 · Immersive Engineering 10.2.0-183 ·
Mekanism 10.4.16.80 · Industrial Foregoing 3.5.22 · Pipez 1.2.26 · **Pollution of the Realms 8.1.49.0** · PneumaticCraft 6.0.23

作用：机械传动/流水线/铁路运输/多块重工业/终极能源/污染治理——**工业文明的代价与荣耀**。

## E. 硅火星 · 信息文明（8）

AE2 15.4.10 · Refined Storage 1.12.4 · CC: Tweaked 1.120.2 · Integrated Dynamics 1.31.0 ·
Integrated Terminals 1.7.0 · Integrated Tunnels 1.10.0 · Chipped 3.0.7 · **Flux Networks（CF）**

作用：存储网络（双路线专精）、Lua 编程、逻辑网络、赛博建材、无线能量。

## F. 苍穹星 · 星际文明（3 + 共用）

Ad Astra 1.15.20 · Ad Astra: Giselle Addon 6.20 · L_Ender's Cataclysm 3.31（+ 共用 Mekanism 反物质能源）

作用：火箭/空间站/月球火星、火箭自动化、史诗 Boss——**星际文明的史诗舞台**。

## G. 冒险与世界生成（8）

Terralith 2.5.4 · YUNG's Better Strongholds 4.0.3 · Better Mineshafts 4.0.4 · Better Dungeons 4.0.4 ·
When Dungeons Arise 2.1.58 · Towns and Towers 1.12 · Structory 1.3.5 · Structory Towers 1.0.7

作用：绿谷星地表多样性 + 全星球上古遗迹的叙事载体（“上一个文明的城市与矿脉”）。

## H. 魔法分支 · 专精路线（3）

Botania 1.20.1-455 · Ars Nouveau 4.12.7 · Patchouli 1.20.1-85

作用：**科技树分支**——不喜欢纯机器的玩家可走“生命科技”（Botania）或“法术工业”（Ars Nouveau）路线；
Patchouli 统一全部手册（史书记录）。

## I. 库 / 前置（11）

KubeJS 2001.6.5-build.26 · Rhino 2001.2.3 · Architectury API 9.2.14 · CraftTweaker 14.0.60(可选) ·
Citadel 2.6.3 · GeckoLib 4.8.4 · Curios 5.14.1 · Placebo 8.6.3 · Cloth Config 11.1.136 ·
Moonlight 2.16.34(原 Selene) · Balm 7.3.42

## J. 可选

- **Oculus**（光影加载器，Modrinth）：安装后可将 Complementary Reimagined 放入 `shaderpacks/` 获得霓虹/星云画质。可选，默认不装（规避渲染兼容风险）。
- CurseForge 手动：**Flux Networks**（无线能量）、**MineColonies**（殖民地）、LazyDFU 兜底——链接见 `scripts/mods.json` 与 `install_mods.ps1` 输出。

## 版本兼容性注意事项

- Create 6.x 与 Create: Steam 'n' Rails 1.7.x 配套（均已验证 1.20.1 Forge）。
- Supplementaries 需要 **Moonlight**（原 Selene）；Waystones 需要 **Balm**（已包含）。
- Embeddium + Oculus 兼容；若两者同时开启遇到渲染异常，先关闭 Oculus 排查。
- 已知冲突规避：不装两个“存储网络”同时驱动同一物品（AE2 与 RS 请二选一专精，包内已通过配方阶段引导）。
- 全部模组来自 Modrinth / CurseForge 官方分发；追随各自许可证（本仓库不含任何 mod jar，安装脚本按官方 CDN 下载）。