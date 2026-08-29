# 星际文明编年史 · Starfall Chronicles

> **你在一片麦田里醒来，头顶是四颗星球。一万年前，上一个文明把种子留在了这里——现在，轮到你沿着星门，把文明重新点亮。**

一个基于 **Minecraft 1.20.1 (Forge 47.4.23)** 的文明主题整合包：四个星球 = 四个文明阶段
（**农耕 → 工业 → 信息 → 星际**），每一个星球都是完全不同的玩法逻辑，而非换皮。
由 **103 个模组（全部 Modrinth 自动安装）+ KubeJS 脚本层 + 自定义数据包 + 资源包**
组合而成——模组只是演员，KubeJS 是导演。依赖经 Modrinth API 审计闭环、配方/进度 ID 经真实 jar 校验、服务端经真实启动冒烟测试。

## ✨ 核心体验

| 星球 | 文明 | 一句话玩法 |
|------|------|-----------|
| 🌾 绿谷星（主世界） | 农耕 | 四季、酿造、养蜂、殖民村落，与自然共生 |
| ⚙️ 铁锈星 `starciv:rustfall` | 工业 | 机械、蒸汽火车、流水线——**污染会反噬你** |
| 🧠 硅火星 `starciv:silicon` | 信息 | AE2/RS 存储网 + Lua 编程，**代码即力量** |
| 🚀 苍穹星 `starciv:stellaris` | 星际 | Ad Astra 火箭 + 反物质能源 + 灾厄 Boss，**物理法则可被改写** |

**跨文明合成链**（禁止各星球独立发展）：
上古之种(绿谷) → 生物燃料(铁锈) → 精密零件 → 量子核心(硅火) → 跃迁引擎(苍穹)。
进度树 27 节点、星门跃迁仪式、终局“失落科技”揭示：**最原始的，才是最先进的。**

## 🚀 快速开始

### 方式 A：PCL2（国内最流行，拖入即用）
1. 运行 `pwsh scripts/build_pcl_pack.ps1`（自动下载模组 + Forge 完整客户端，仅首次耗时）。
2. 得到 dist/starfall-chronicles-pcl-*.zip → 把 zip **直接拖进 PCL2 窗口**（或首页 → 安装整合包 → 选择文件）即可一键安装。
3. 选版本 **1.20.1-forge-47.4.23** 启动；进游戏后启用资源包。详细步骤见 [docs/08](docs/08-launcher-guide.md)。
   提示：也提供 Modrinth 格式 dist/starfall-chronicles-*.mrpack，拖入 PCL2/Prism 窗口同样自动识别安装（双格式兜底，任选其一）。

### 方式 B：Prism Launcher
1. 确认 [Java 17](https://adoptium.net/) 已安装。
2. 运行 `scripts/install_mods.ps1 -IncludeOptional` 下载 103 个模组到 `pack/.minecraft/mods/`
   （或 `bash scripts/install_mods.sh`；LazyDFU/MineColonies 等 4 个 CurseForge 手动链接会打印出来）。
3. 运行 `scripts/make_zip.ps1` → Prism「添加实例 → 从文件导入」选择 `dist/*.zip`。
4. 数据包无需手动启用：自定义内容（手册/成就/维度）由 kubejs/data 内建，任何世界自动生效。
5. 「选项 → 资源包」启用 `starciv_resources`。分配 6-8GB 内存，开玩！

### 方式 C：开服联机（一键脚本）
```powershell
cd server; ./start-server.ps1        # 自动装 Forge → 同步模组 → 启动
```
详见 [server/README-server.md](server/README-server.md)。

### 方式 D：手动（任意启动器）
新建 1.20.1 + Forge 47.4.23 实例 → 下载模组（同上）→ 把 `kubejs/`、`datapacks/`、`resourcepacks/` 复制进 `.minecraft` → 见 [docs/03](docs/03-technical.md) §4。

> ⚠️ Minecraft **不会**自动加载全局数据包目录，务必在创建世界时启用 `starciv_dp`（详见 [docs/03](docs/03-technical.md)）。

## 📦 仓库结构

```
├─ pack/                      # 可运行的整合包本体（Prism 实例 / PCL 数据源）
│  └─ .minecraft/
│     ├─ kubejs/              # 脚本层（物品/配方/阶段/事件/星门）
│     ├─ datapacks/starciv_dp # 维度/群系/进度树/战利品/函数/Patchouli 任务书
│     └─ resourcepacks/…      # 语言文件、程序化纹理、主菜单视觉与音乐
├─ scripts/                   # 下载/校验/审计/打包/PCL构建/冒烟/资源生成脚本
├─ server/                    # 专用服务器一键启动（start-server.ps1/.sh）
├─ docs/                      # 完整设计文档（01-09）
├─ launch/jvm-args.txt        # JVM 参数（另有 jvm-args-low.txt 低配档）
└─ mods 由 install 脚本下载   # 不内嵌任何 jar（尊重模组许可）
```

## 🧰 常用脚本

| 命令 | 作用 |
|------|------|
| `pwsh scripts/install_mods.ps1 -IncludeOptional` | 从 Modrinth 下载全部模组（103 个） |
| `pwsh scripts/audit_deps.ps1` | 依赖审计（Modrinth API 实时核对 required/incompatible） |
| `pwsh scripts/verify_mod_ids.ps1` | 用真实 jar 校验配方/进度引用的物品/实体 ID |
| `pwsh scripts/validate.ps1` | 校验全部 JSON/JS/进度引用/mcfunction 行尾 |
| `pwsh scripts/server_smoke_test.ps1` | 端到端服务器启动冒烟测试（数据包+维度+RCON） |
| `pwsh scripts/build_pcl_pack.ps1` | 构建 PCL2 拖入即用的离线整合包（含光影/材质/任务书） |
| `pwsh scripts/make_zip.ps1` | 打包为 Prism 可导入 zip |
| `pwsh scripts/build_textures.ps1` | 再生成纹理 PNG（仓库已含成品） |
| `pwsh scripts/build_assets.ps1` | 再生成主菜单视觉（Logo/全景/标语/图标） |
| `pwsh scripts/build_music.ps1` | 再生成音乐（需本地 ffmpeg，见文档 09） |

## 🗺️ 文档目录

- [01 · 概念设计](docs/01-concept.md) — 文明阶梯、模组-叙事映射、主线大纲、经济系统
- [02 · 模组清单](docs/02-modlist.md) — 103 模组逐条“为什么需要”（+4 CurseForge 可选清单）
- [03 · 技术实现](docs/03-technical.md) — KubeJS 配方/进度/事件、数据包、性能方案
- [04 · 内容创作](docs/04-content.md) — 开局引导、星门仪式、Boss 设计
- [05 · 发布与社区](docs/05-release-and-community.md) — 平台、安装、运营、扩展
- [06 · 性能](docs/06-performance.md) — JVM 参数、配置矩阵、3050/低配优化
- [07 · 故障排查](docs/07-troubleshooting.md) — 常见问题、冲突、存档迁移
- [08 · 启动器指南](docs/08-launcher-guide.md) — PCL2 / Prism / 服务器 / 低配优化速查
- [09 · 任务书与视听](docs/09-quest-and-aesthetics.md) — Questlog 任务书 + Patchouli 手册、光影/材质、音乐、主菜单定制

## 🖥️ 服务器

`server/` 内含一键开服脚本（Windows PowerShell / Linux bash），自动完成 Java 检测、Forge 47.4.23 安装、模组同步、数据包放置与启动。详见 [server/README-server.md](server/README-server.md)。

## 📜 许可证

本仓库（文档、脚本、数据包、资源包、KubeJS 代码）：**MIT**（见 [LICENSE](LICENSE)）。
模组本体按各自许可证分发；仓库不含任何 mod jar。发布整合包时请注明模组原作者。