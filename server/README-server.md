# Starfall Chronicles — 专用服务器（Dedicated Server）

只需三步即可开服，无需手装 Forge。

## 快速开始

### Windows
```powershell
cd server
./start-server.ps1
```
首次运行会自动：检测 Java 17 → 下载并安装 Forge 1.20.1-47.4.23 → 询问并接受 EULA → 从 `pack/.minecraft/mods` 同步全部模组 → 启动服务器。
如果之前已开过服，再次运行会自动把数据包放入 `world/datapacks/starciv_dp`。

### Linux / macOS
```bash
cd server
chmod +x start-server.sh
./start-server.sh          # 或 ./start-server.sh --eula 自动接受 EULA
```

### 常用参数
| 命令 | 作用 |
|---|---|
| `./start-server.ps1 -AcceptEula` / `./start-server.sh --eula` | 跳过 EULA 询问 |
| `./start-server.ps1 -SyncOnly` / `./start-server.sh --sync` | 只同步模组和数据包，不启动 |
| 手动启动 | Windows：`java @user_jvm_args.txt @libraries\net\minecraftforge\forge\1.20.1-47.4.23\win_args.txt nogui`；Linux：`java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-47.4.23/unix_args.txt nogui` |

> 同步时自动**剔除纯客户端模组**（如光影加载器 Oculus，它的加载会导致服务端直接崩溃），服务端实际加载 91 个模组；玩家客户端可额外使用光影模组，不影响联机。
> 启动脚本会**自动同步 KubeJS 脚本目录**（自定义物品、配方、文明阶段全部由脚本定义，缺失会导致自定义内容不生效）与**数据包**（世界已生成后自动放入 `world/datapacks/`）。

## 首次启动的两次问题（重要）

Forge 服务器**第一次**启动才会生成 `world/` 目录，而数据包必须位于世界内部。
- 第 1 次启动：生成世界（建议直接输入 `stop` 退出）。
- 第 2 次启动：脚本自动把 `starciv_dp` 数据包放进 `world/datapacks/`，完整内容（3 个自定义维度、27 个进度、星门函数等）生效。
> 也可以手动复制：`pack/.minecraft/datapacks/starciv_dp` → `server/world/datapacks/`。

## 服务端与客户端一致性

- 服务端模组 = 客户端模组（脚本从同一个 `pack/.minecraft/mods` 同步）。
- 联机时所有玩家客户端**必须**与本包客户端一致（同模组、同数据包）。
- `online-mode=true` 开启正版验证；局域网/离线可改为 `false` 并各自添加白名单。

## 内存档位

编辑 `server/user_jvm_args.txt`：
- 6G 推荐档（8GB 内存机器跑 8 人服）：默认配置。
- 轻量 4G 档（6GB 内存）：`-Xmx4G -Xms2G` 并删除 `-XX:+AlwaysPreTouch`。
- 开服机内存 ≥16GB 可上 8G：`-Xmx8G`。

## 常用管理命令（服务器控制台）

```
stop                 # 优雅停服
save-all             # 手动存档
list                 # 在线玩家
whitelist add 玩家名
op 玩家名
seed                 # 查看种子（方便玩家同步）
/execute in starciv:rustfall run tp @p 0 100 0   # 测试用：传送到铁锈星
```

## 其它

- 服务端生成的 `world/`、`libraries/`、`mods/`、`logs/`、`eula.txt`、`server.properties` 等均由脚本生成，已加入 `.gitignore`，不会进入仓库。
- 想改服务器名/MOTD/人数：编辑启动后生成的 `server.properties`（或把 `server.properties.example` 复制为 `server.properties` 后改）。
- 端口：默认 25565；如需更改在 `server.properties` 里改 `server-port` 并**同步开放防火墙**。