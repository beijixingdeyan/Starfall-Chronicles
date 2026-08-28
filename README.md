# 星际文明编年史 · Starfall Chronicles

> **你在一片麦田里醒来，头顶是四颗星球。一万年前，上一个文明把种子留在了这里——现在，轮到你沿着星门，把文明重新点亮。**

一个基于 **Minecraft 1.20.1 (Forge 47.4.53)** 的文明主题整合包：四个星球 = 四个文明阶段
（**农耕 → 工业 → 信息 → 星际**），每一个星球都是完全不同的玩法逻辑，而非换皮。
由 **78 个模组 + KubeJS 脚本层 + 自定义数据包 + 资源包**组合而成——模组只是演员，KubeJS 是导演。

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

## 🚀 快速开始（2 分钟）

### 方式 A：Prism Launcher（推荐）
1. 确认 [Java 17](https://adoptium.net/) 已安装。
2. 运行 `scripts/install_mods.ps1` 下载 75 个模组到 `pack/.minecraft/mods/`
   （或 `bash scripts/install_mods.sh`；CurseForge 独有 3 个模组的链接会打印出来，手动放入）。
3. 运行 `scripts/make_zip.ps1` → 在 Prism 里「添加实例 → 从文件导入」选择 `dist/*.zip`。
4. **创建世界时启用数据包**：更过 → 数据包 → 打开文件夹 → 拖入 `pack/.minecraft/datapacks/starciv_dp/` → 选中启用。
5. 「选项 → 资源包」启用 `starciv_resources`。分配 6-8GB 内存，开玩！

### 方式 B：手动（任意启动器）
新建 1.20.1 + Forge 47.4.53 实例 → 下载模组（同上）→ 把 `kubejs/`、`datapacks/`、`resourcepacks/` 复制进 `.minecraft` → 见 [docs/03](docs/03-technical.md) §4。

> ⚠️ Minecraft **不会**自动加载全局数据包目录，务必在创建世界时启用 `starciv_dp`（详见 [docs/03](docs/03-technical.md)）。

## 📦 仓库结构

```
├─ pack/                      # 可运行的整合包本体（Prism 实例）
│  └─ .minecraft/
│     ├─ kubejs/              # 脚本层（物品/配方/阶段/事件/星门）
│     ├─ datapacks/starciv_dp # 维度/群系/进度树/战利品/函数
│     └─ resourcepacks/…      # 语言文件与程序化纹理
├─ scripts/                   # 安装/校验/打包/纹理生成脚本
├─ docs/                      # 完整设计文档（01-07）
├─ launch/jvm-args.txt        # JVM 参数
└─ mods 由 install 脚本下载   # 不内嵌任何 jar（尊重模组许可）
```

## 🧰 常用脚本

| 命令 | 作用 |
|------|------|
| `pwsh scripts/install_mods.ps1` | 从 Modrinth 下载全部模组 |
| `pwsh scripts/validate.ps1` | 校验全部 JSON/JS/进度引用 |
| `pwsh scripts/build_textures.ps1` | 再生成纹理 PNG（仓库已含成品） |
| `pwsh scripts/make_zip.ps1` | 打包为 Prism 可导入 zip |

## 🗺️ 文档目录

- [01 · 概念设计](docs/01-concept.md) — 文明阶梯、模组-叙事映射、主线大纲、经济系统
- [02 · 模组清单](docs/02-modlist.md) — 78 模组逐条“为什么需要”
- [03 · 技术实现](docs/03-technical.md) — KubeJS 配方/进度/事件、数据包、性能方案
- [04 · 内容创作](docs/04-content.md) — 开局引导、星门仪式、Boss 设计
- [05 · 发布与社区](docs/05-release-and-community.md) — 平台、安装、运营、扩展
- [06 · 性能](docs/06-performance.md) — JVM 参数、配置矩阵
- [07 · 故障排查](docs/07-troubleshooting.md) — 常见问题、冲突、存档迁移

## 📜 许可证

本仓库（文档、脚本、数据包、资源包、KubeJS 代码）：**MIT**（见 [LICENSE](LICENSE)）。
模组本体按各自许可证分发；仓库不含任何 mod jar。发布整合包时请注明模组原作者。