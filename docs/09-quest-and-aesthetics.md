# 09 · 任务书与视听体验

> 本包在“能玩、不冲突、性能好”之上进一步打磨：**任务书（Patchouli）、光影与材质、音乐、主菜单视觉**，全部零版权风险、可离线使用。

## 1. 任务书《星际文明编年史 · 探索手册》

- 载体：**Patchouli**（已在模组清单中，`data/starciv/patchouli_books/handbook/`）。
- 每次进入世界赠予一本；遗失可 **书 + 羽毛** 合成补办（`kubejs/server_scripts/recipes/guide.js`）。
- 结构：5 大分类 × 16 词条，与主线完全对齐：
  - `〇 成为文明`：开局、阶段规则、性能建议
  - `Ⅰ 绿谷星`：上古之种、农田与四季、星门钥匙
  - `Ⅱ 铁锈星`：抵达、机械与产线、生物燃料
  - `Ⅲ 硅火星`：抵达、自动化与存储、量子核心
  - `Ⅳ 苍穹星`：抵达、终局跃迁引擎
- 词条中的合成配方页直接读取真实配方（配方 id 已在 KubeJS 中显式写明，如 `kubejs:stellar_key`、`kubejs:civ_essence_from_seed`），不会出现“手册配方与游戏不一致”。

## 2. 星球特色建筑（代码生成，不破坏地形）

世界首次加载时 KubeJS 在**四大星球**各生成一处与星球环境匹配的建筑（`worldgen/structures.js`）：

| 星球 | 建筑 | 环境定位 |
|------|------|----------|
| 绿谷星 | 果园祭坛（麦田+篝火+水源） | 农耕文明的田园小品 |
| 铁锈星 | 锈蚀工厂遗迹（高炉+料斗+铁栅窗） | 工业文明的废墟地标 |
| 硅火星 | 霓虹数据塔（石英+紫水晶+信号灯） | 信息文明的都市剪影 |
| 苍穹星 | 上古神庙（末地石柱+绿宝石祭坛） | 星际文明的精神原点 |

- 建筑与各星球**群系审美一致**，不引入无关风格的乱建。
- 全部由 `execute in <维度> run setblock` 构建，无外部 NBT，兼容性 100%。
- 维度未就绪时自动延后到下一次启动，**绝不误置位**（修复了“首次启动置位导致重启后跳过生成”的隐患）。

## 3. 光影与材质

- **光影**（装在 `shaderpacks/`，需 **Oculus** 模组，1.20.1 Forge 客户端标配）：
  - `Complementary Reimagined`（推荐）：硅火霓虹夜景与苍穹星星云天空的最佳视觉底。
  - `MakeUp - Ultra Fast`（低配首选）：3050 / 核显也流畅。
  - 服务器**不**同步 shaderpacks（纯客户端，已在 start-server 脚本排除 oculus 同理）。
- **材质/建筑资源包**：`Better Vanilla Building`（1000+ 原版风格新方块；16x，性能开销可忽略）+ 本包专属 `starciv_resources`（自定义物品纹理、主菜单视觉、音乐）。
- 资源包默认在 PCL 包的 `options.txt` 中启用，可随时在游戏内调整顺序或关闭。

## 4. 音乐

| 场景 | 曲目 | 来源 |
|------|------|------|
| 主菜单 | 「Calm Ambient 1 (Synthwave 4k)」（裁剪 3 分钟循环） | OpenGameArt，**CC0** |
| 创造模式 | 「星港低语」（合成氛围 pad，降 B 大调） | ffmpeg 纯算法合成，公有领域 |
| 末地/终局 | 「苍穹回响」（三音叠层 pad，e 小调） | ffmpeg 纯算法合成，公有领域 |

- 通过 `assets/minecraft/sounds.json` 覆盖 `music.menu / music.creative / music.end`，只加不删（其余原版音乐保留）。
- 版权声明见 `resourcepacks/starciv_resources/CREDITS.txt`。
- 重新构建：`pwsh scripts/build_music.ps1`（需 `downloads/ffmpeg`，见脚本内说明）。

## 5. 主菜单视觉

- 标题 Logo：**「星 际 文 明 编 年 史 / STARFALL CHRONICLES」**（金色渐变 + 阴影，`minecraft.png`）。
- 副标：`星际文明编年史 · 1.20.1 · Forge`（`edition.png`）。
- 全景动画 6 面：程序化星空（四星球主题色 + 星云 + 光环）。
- 标语池 12 条（`splashes.txt`）：如“绿谷的麦田在等你。”“最原始的，才是最先进的。”
- 全部由 `pwsh scripts/build_assets.ps1` 用 System.Drawing 生成，离线、零版权依赖。

## 6. 性能影响

- 全景/Logo：启动时一次性载入，常驻显存 < 8MB。
- 音乐：ogg 流式播放，常驻内存 < 10MB。
- 光影：可选；关光影帧数不变（与 vanilla 完全一致）。
- 材质：16x，与 vanilla 同开销。
- 结论：视听层对 3050/低配**无实质负担**。

## 世界真实感增强（2026-08 增补）

- **地形**：新增 **Tectonic**（板块造山：真高山/峡谷/侵蚀海岸，与 Terralith 官方声明兼容）与 **Regions Unexplored**（竹林/红树林/樱林/荒漠绿洲等生态群系，经 TerraBlender 注入）。主世界（绿谷星）现在拥有层次感极强的山地、曲折水系与丰富生态带。
- **水**：水流动/波浪/反光由光影（Complementary Reimagined）呈现；**Clear Water** 提供清水质感与水下能见度（纯客户端）。
- **落叶**：**Falling Leaves** 让树木随季节与风飘落叶片粒子（纯客户端）。与 Serene Seasons 搭配，秋季林带"落叶感"拉满。
- **动物**：在原 Alex's Mobs（60+ 生物）与 Naturalist（陆禽/海龟/熊等）基础上新增 **Frikinzi's Fauna**（珊瑚鱼/寄居蟹/鹦鹉螺等轻量萌物），水岸生机更足。
- **说明**：以上均为可选观感增强，服务端同步启用但仅影响世界生成与实体；三颗自定义星球（铁锈/硅火/苍穹）为固定群系，不受新世界生成 mod 影响，性能开销集中在主世界——3050 上配合原性能优化（modernfix/embeddium/ferritecore/saturn 等）仍可流畅。