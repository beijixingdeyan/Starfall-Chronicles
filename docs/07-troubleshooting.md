# 07 · 故障排查

## 1. 常见问题快速索引

| 症状 | 原因 | 解决 |
|------|------|------|
| 启动到 90% 卡住/崩溃 | 内存不足或 Java 版本不对 | 用 Java 17 / 按 docs/06 加 `-Xmx6G` |
| 主菜单 5 分钟未出 | DFU 未降级 | 确认 ModernFix 已装；检查 mods 目录是否有重复 jar |
| 进世界后星门不存在 | 数据包未启用 | docs/03 §4：创建世界时启用 `starciv_dp` |
| 右键星门核心没反应 | 未达阶段 / 缺燃料 / 无钥匙 | 看聊天提示；按主线走（docs/01） |
| 自定义维度报错“Invalid dimension” | 数据包未加载 | `/datapack list` 检查；`/reload` |
| 进度树不显示 | 进度属于数据包 | 同上；单人需在世界创建时勾选 |
| 物品显示紫黑方块 | 资源包未启用 | 选项→资源包→启用 `starciv_resources` |
| 模组缺前置崩溃 | 安装脚本漏装 | 重跑 `install_mods.ps1`；手动装 CurseForge 独有项 |

## 2. KubeJS 脚本问题

- 日志：`logs/kubejs/server.log`。
- 热重载：`/kubejs reload server_scripts`（单机也有效）。
- 常见误区：改完 `startup_scripts` 必须**重启游戏**（注册表在启动时固定）。
- 阶段被卡住：`/kubejs stage add <玩家> industrial` 手动补阶段（管理员）。

## 3. 已知冲突与规避

| 冲突 | 规避 |
|------|------|
| AE2 × Refined Storage 同控一体系 | 二选一专精（包内已按阶段引导） |
| Embeddium × Oculus 渲染异常 | 先关 Oculus；确认版本配套（见 02） |
| 多个“结构生成”模组重叠房屋 | 冲突由世界种子重复生成导致，无功能损害；可用 `Repurposed Structures` 等替换其一时注意 YUNG's 与 When Dungeons Arise 的兼容性提示 |
| 光影 + FastSuite 同开偶发贴图错乱 | FastSuite 保留、光影关闭时贴图正常 |

## 4. 崩溃处理流程

1. 复制 `crash-reports/` 最新报告 + `logs/latest.log`。
2. 运行 `scripts/validate.ps1` 确认包内 JSON/JS 无错。
3. 用 Spark：`/spark profiler` 抓取后停止（`/spark profiler stop`）生成火焰图。
4. Issue 模板贴三者（日志去掉敏感路径）。

## 5. 存档迁移（版本升级）

- 轻微升级（配方/进度调整）：旧存档直接可用；进度树新增节点会自动补树。
- 维度/群系升级：新维度自动生成，旧区块保留原样（不回填）。
- 大版本（跨 MC 版本）：建议「新世界 + 资源搬运」（Sophisticated Backpacks 整包搬运）；
  存档迁移从 1.20.1 开始记录，Futureproof 策略为不跨大版本承诺。
- 迁移工具：社区可贡献 `scripts/migrate_save.ps1`（备份+校验+复制）至仓库。

## 6. 多人服务器

- 服务端内存 ≥ 8G；`server.properties` 建议 `view-distance=8`。
- 星门/进度/污染均为服务端逻辑，玩家无需额外装 KubeJS（服务端脚本即生效）。
- 管理命令：`/kubejs stage`（阶段）、`/advancement grant @s only starciv:*`（调试进度）、
  `function starciv:quest/seed_gift`（补发种子）。

## 数据包/脚本易错点（实战验证 2026-08）

1. **群系要素重复引用 → Feature order cycle 崩溃**：自定义群系 JSON 的 eatures 列表里同一 placed feature 出现两次（如 minecraft:ore_diamond ×2）会让 FeatureSorter 产生自环，首次生成该维度区块时崩溃（InvalidDataException: Feature order cycle found，且会导致服务器 tick 卡死触发 Watchdog）。症状：第二启动（数据包生效后）在生成自定义维度区块时秒崩。**每个 placed feature 在同一个 biome 的 features 中只能出现一次。**
2. **KubeJS 脚本共享顶层作用域**：多个文件顶部 const SC = ... 会 edeclaration of const，导致整文件不加载（星门/传送等静默失效）。全包现统一为单一事实源 global.SC，事件回调内用 ar。
3. **本 KubeJS 构建的 modded 机器配方签名不兼容**（create:mixing/milling、mekanism:enriching/crushing 的构造器报错）——本包已全部改为数据包 JSON 配方，若自行添加请复制 data/starciv/recipes/enrich_seed.json 的写法。
4. **IF 自带进度引用 orge:plastic 会报 “Unknown item id”**：这是 Industrial Foregoing 自身的进度数据问题（其假装依赖未知物品），不影响启动与游玩，属良性噪音。