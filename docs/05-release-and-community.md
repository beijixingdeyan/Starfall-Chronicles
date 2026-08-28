# 05 · 发布与社区（Phase 4）

## 目标平台

- **GitHub（本仓库）**：源码/文档/数据包/资源包/脚本——唯一事实源（无 mod jar）。
- **Modrinth / CurseForge**：发布打包后的整合包（依赖 Modrinth/CF 自动依赖，无需内嵌 jar）。
- **自建镜像**：`dist/` 下的打包 zip 供直链分发。

## 安装方式

| 方式 | 步骤 |
|------|------|
| **Prism Launcher（推荐）** | `scripts/make_zip.ps1` 打包 → 添加实例 → 从文件导入 zip；或直接把 `pack/` 目录放入 `instances/`（含 mmc-pack.json 与 instance.cfg） |
| **手动（任何启动器）** | 建 1.20.1-Forge 47.4.53 实例 → 运行 `scripts/install_mods.ps1` 下载模组 → 启用数据包/资源包（见 docs/03 §4） |
| **一键（服务器）** | 服务端运行 `install_mods.sh`（Linux）→ 放入 world/datapacks → `/reload` |

## 社区运营

1. **反馈收集**：GitHub Issues 模板（崩溃报告勾选 Spark 报告 + crash-reports/ 日志路径）。
2. **模组更新管理**：`scripts/mods.json` 为唯一数据源——升级即改 slug/版本快照，
   重跑 install 脚本；KubeJS 配方全部用 mod id 引用，模组小版本升级一般无需改脚本。
3. **冲突处理**：docs/07 的已知冲突清单 + 贡献者 PR 流程；加入 `validate.ps1` 到 CI（一键校验全部 JSON/JS）。
4. **B 站/红石频道宣传**：四星球对照视频 + “最原始的才是最先进的”结局镜头。

## 扩展计划

- **DLC 星球**：数据包即插即用（换 `biome_source` + 一个群系 JSON + 星门记录），
  预留多周目星球（熵增星）。
- **社区投稿星球**：提供「星球模板」文档（维度 + 群系 + 进度 + 星门规则表）。
- **多人服务器**：MineColonies 殖民地赛、铁锈星污染治理排行榜、
  苍穹星戴森球完成度比分——本包所有阶段与数据均为服务端可同步。
- **New Game+**（多周目）：保留进度阶段（`/kubejs stage` 延续），新增宇宙熵增事件（后续数据包内建）。

## 许可证

- 本仓库代码/文档/数据包/资源包：**MIT**（见 LICENSE）。
- 模组本体遵循各自许可证；本仓库不含任何 mod jar（下载走官方 CDN）。
- 发布到 Modrinth/CurseForge 时请在描述页注明模组原作者与许可。