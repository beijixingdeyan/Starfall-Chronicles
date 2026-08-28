# KubeJS 脚本层说明（Starfall Chronicles）

本目录是本整合包的“导演脚本”：让数十个模组在一个世界里讲一个连贯故事。

```
kubejs/
├─ startup_scripts/registry.js       物品/方块注册（命名空间 starciv）
└─ server_scripts/
   ├─ settings.js                    全局配置（维度/阶段/传送规则表）
   ├─ stages.js                      文明阶段系统（抵达新星球自动升级）
   ├─ tags.js                        物品标签
   ├─ recipes/                       配方（按星球分文件）
   │  ├─ agriculture.js
   │  ├─ industry.js
   │  ├─ information.js
   │  ├─ interstellar.js
   │  └─ cross_civilization.js       跨文明合成链总览
   └─ events/
      ├─ welcome.js                  首次进入：史书 + 指引
      └─ worldgen/
         ├─ structures.js            星门/独石碑代码建造（setblock 生成）
         └─ stargate_interact.js     星门传送 + 遗迹发现
```

## 核心机制

1. **文明阶段（Stages）**：`agricultural`（初始）→ `industrial` → `information` → `interstellar`。
   到达新维度即自动解锁（见 stages.js，基于 tick 轮询，不依赖版本敏感事件）。
2. **配方锁定**：所有跨文明配方带 `.stage('...')`，未达阶段无法在 JEI 中合出。
3. **跨文明合成链**（本包核心卖点）：
   - 上古之种（绿谷）→ 生物燃料（铁锈，Create 混合）
   - 精密零件（铁锈）→ 量子核心（硅火，AE2 处理器）
   - AI 核心（硅火）→ 跃迁引擎（苍穹，Ad Astra 引擎框架）
4. **星门**：四座星门由 structures.js 在世界加载时用 `setblock` 生成
   （绿谷星门在主世界出生点附近，其余星球在各自维度）。
   右键「星门核心」按规则表跃迁，规则见 settings.js `warp_rules`。

## 自定义事件示例（数据包配合）

- 首航铁律：非工业阶段玩家必须持有「星门钥匙」才能离开绿谷星。
- 跃迁标题：`title` 命令 + 60 tick 延迟调度。
- 遗迹发现：独石碑半径 20 格探测，发放上古之种（30 分钟冷却）。

## 调试

- KubeJS 日志在 `logs/kubejs/server.log`。
- 游戏内 `/kubejs hand`、`/kubejs hot`、`/kubejs reload server_scripts` 可热重载脚本。
- 手动加阶段：`/kubejs stage add <玩家> industrial`（需 KubeJS 6 命令权限）。

> 版本兼容：本包面向 KubeJS 6（1.20.1，构建 2001.6.x）。若 KubeJS 升级大版本，
> 优先检查 `event.server.persistentData`、`PlayerEvents.tick`、`BlockEvents.rightClicked`
> 与配方 `.stage()` 四个 API 是否变动。