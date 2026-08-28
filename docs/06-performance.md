# 06 · 性能与稳定性

目标：**6-8GB 流畅 / 12GB 极致画质；启动到主菜单 < 5 分钟；正常游戏 4 小时不崩溃。**

## 1. 优化模组矩阵（11 个，见 docs/02 A 类）

| 目标 | 模组 |
|------|------|
| 启动时间 | ModernFix（DFU 降级/动态资源）、LazyDFU、Embeddium |
| 渲染帧率 | Embeddium、EntityCulling、Saturn |
| 内存占用 | FerriteCore、MemoryLeakFix、ModernFix |
| 合成/熔炉 | FastSuite、FastWorkbench、FastFurnace |
| 分析 | Spark |

## 2. JVM 参数

6-8GB 标准（已写入 `pack/instance.cfg`）：
```
-Xmx6G -Xms2G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200
-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:G1NewSizePercent=30
-XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20
-XX:G1MixedGCCountTarget=4 -XX:SurvivorRatio=32 -XX:+AlwaysPreTouch
-Dfml.ignorePatchDiscrepancies=true -Dfml.ignoreInvalidMinecraftCertificates=true
```
12GB 极致：仅改 `-Xmx12G -Xms4G`。启动器 Java 建议 **Java 17 (64-bit)**（Forge 47 官方要求）。

## 3. 配置调整（低配→高配）

| 项 | 低配(6G) | 标准(8G) | 极致(12G+) |
|----|----------|----------|-----------|
| 渲染距离 | 8 | 10 | 14+ |
| 光影 | 关 | 可选 Oculus | Complementary Reimagined |
| 粒子 | 减少 | 全部 | 全部+爆炸 |
| Embeddium 景深/模糊 | 关 | 关 | 开 |
| 远端视野 OptiFine 替代 | ModernFix | ModernFix | ModernFix |

## 4. 稳定性策略

- **冲突规避**：AE2/RS 双存储二选一专精；不叠加两个同职渲染模组；Embeddium+Oculus 组合在 `--skip` 时按 docs/07 排查。
- **周期体检**：`/spark tps`、`/spark heapsummary`；多人服建议 8G+。
- **存档安全**：定期备份 `saves/`；版本升级走“存档迁移”流程（docs/07 §5）。
- **崩溃报告**：`crash-reports/` 目录自动生成；提交 Issue 时附上 `logs/latest.log`。

## 5. 加载时间预算（<5 分钟）

ModernFix 的 DFU 降级 + LazyDFU 懒加载：冷启动（首次）约 3-4 分钟，热启动 1-2 分钟属正常；
首次进世界因生成四个维度会稍慢（生成星门结构），之后每次进图 <1 分钟。

## 6. RTX 3050 / 低配笔记本三档设置

RTX 3050（含 4GB 显存版）跑本包 1080p 无压力；以下从“最舒服”到“能玩”三档：

| 档位 | 场景 | JVM | 渲染/模拟距离 | 画质 | 光影 |
|------|------|-----|--------------|------|------|
| 一档 | 3050 默认 | `launch/jvm-args.txt`（6G） | 12 / 8 | 高 | 可选 Complementary（关体积云） |
| 二档 | 3050 要满帧 + 光影 | 6G 档 | 10 / 6 | 高、粒子少量 | Complementary·Fast 预设，上限 90fps |
| 三档 | 核显 / 老笔记本 8G 内存 | `launch/jvm-args-low.txt`（4G） | 6-8 / 4 | 流畅 | 关 |

通用规则（3050 尤其注意）：
1. 内存给物理内存一半以内：8GB 机 -> `-Xmx4G`；16GB 机 -> 6-8G。
2. 插电 + NVIDIA 控制面板把 `javaw.exe` 设为**高性能独显**（笔记本核显误载是掉帧头号原因）。
3. 卡顿优先降**模拟距离**（吃 CPU/内存）而非渲染距离；粒子“少量”可在铁锈星烟雾场景明显提质。
4. Embeddium 内开启「区块淡入」可消除跳图顿感；关闭「粒子渲染优化断言」避免少数粒子闪烁。
5. 开光影后若显存吃满（4GB 版 3050），把 Complementary 预设改为 Fast 或关闭「体积雾/体积云」「反射」。
6. 首次进新维度会编译着色器（卡 5-15 秒），之后不再发生；属正常现象。