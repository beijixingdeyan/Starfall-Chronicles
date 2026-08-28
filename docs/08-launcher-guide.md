# 启动器指南：PCL2 · Prism · 专用服务器 · 低配优化

本文是「安装与运行」的最终答案。三种玩法任选其一：单机（PCL2 / Prism）、联机（专用服务器 + PCL2 客户端）、纯单机极简（Prism 导入 zip）。

---

## 1. PCL2（最流行，拖入即用）

### 方式 A：导入离线整合包（推荐，一次到位）

1. 在本仓库根目录执行一次构建（自动下载 Forge 完整客户端 + 全部模组，约 1.5GB）：
   ```powershell
   .\scripts\build_pcl_pack.ps1
   ```
   产出 `dist/starfall-chronicles-pcl-<日期>.zip`（体积约 380-400MB，内含 `.minecraft/versions/1.20.1-forge-47.4.23` 完整运行环境与 92 个模组）。
2. PCL2 → 首页 → **安装整合包 → 导入本地整合包** → 选择该 zip。
3. 安装完成后在版本列表选择 **1.20.1-forge-47.4.23** 启动。
4. 启动前在 **设置 → 启动选项/版本设置** 把 **Java 版本** 指向 Java 17（推荐 Temurin 17）。
5. 进游戏后：**选项 → 资源包** 启用 `星际文明编年史`。

> 不想/无法用 Java 构建？见方式 B。

### 方式 B：PCL2 自动装 Forge

1. PCL2 → 下载 → 安装 **Forge 1.20.1-47.4.23**（PCL 会自动下载）。
2. 打开下载好的模组 zip？不——直接打开本仓库的 `pack/.minecraft`：把其中 `mods/`、`datapacks/`（新建）分别拷入 PCL2 该版本对应的游戏目录（PCL2 **设置 → 游戏目录**，或右键版本 → 打开游戏目录）：
   - `mods/` → 游戏目录 `mods/`
   - `datapacks/starciv_dp` → 游戏目录 `datapacks/starciv_dp`（注意：**单机世界的数据包在创建世界时启用**，见下）
   - `resourcepacks/starciv_resources` → 游戏目录 `resourcepacks/`
3. 创建世界时点击 **数据包…**，启用 `starciv_dp` 后确认（会出现「是否接受数据包更改」提示，选允许）。
4. 进游戏启用资源包。

### 数据包启用（PCL2 与 Prism 单机都适用，易踩坑）

Vanilla **不自动加载** `.minecraft/datapacks`：单机必须在**创建世界时**勾选启用，或对已有世界：
- 打开世界文件夹（ESC → 对世界点「…」→ 打开文件夹），把 `starciv_dp` 复制进 `datapacks/`，再进入世界 → 聊天栏执行 `/reload`。

---

## 2. Prism Launcher（欧式整合包管理，支持版本隔离）

1. 首次：`.\scripts\make_zip.ps1` 生成 `dist/starfall-chronicles-<日期>.zip`。
2. Prism → 添加实例 → **从压缩包导入** → 选该 zip（zip 内是 `.minecraft/*`）。
3. 实例页 → 设置 → Java → 选 Java 17。
4. 启动并选择「新建世界」；创建界面勾选数据包 `starciv_dp`。

仓库内已随包携带 Prism 实例配置（`pack/instance.cfg`、`pack/mmc-pack.json`、`pack/instance.json`），直接导入即可。

---

## 3. 专用服务器（联机）

见 [`server/README-server.md`](../server/README-server.md)：

```powershell
cd server
./start-server.ps1        # Windows
# 或
./start-server.sh          # Linux/macOS
```

脚本自动完成：检测 Java 17 → 安装 Forge 47.4.23 → 同步模组 → 放置数据包 → 启动。首次启动两次（先生成世界、再自动放入数据包）即可完整运行。

- 服务器配置：`server/server.properties.example`（改 MOTD/人数/端口）。
- 玩家客户端：PCL2 或 Prism 安装同一整合包（模组必须一致）。
- 联机时创建世界也无需另配数据包——服务端世界自带。

---

## 4. 低配优化（RTX 3050 / 轻薄本档）

RTX 3050 满血接近中端，**开本包 1080p 60fps 轻松**；以下给 3050 与更弱机器的三档：

### 档位一（3050 默认推荐）
| 项 | 值 |
|---|---|
| 渲染距离 | 12 |
| 模拟距离 | 8 |
| 画质 | 高 |
| 光影（可选，装 Oculus） | Complementary Reimagined ← 关闭「体积云/体积雾」，AO 改 Fast |
| Embeddium 选项 | 打开「区块淡入」，关闭「图元剔除断言」 |

### 档位二（3050 开最舒服光影 / 4C8T 老 CPU）
| 项 | 值 |
|---|---|
| 渲染距离 | 10，模拟距离 6 |
| 画质 | 高，粒子「少量」 |
| 光影 | Complementary Reimagined，性能模式（光影包在设置里选「Fast」预设） |
| 视频设置 | 帧率上限 120（或 VSync 关，上限 90） |

### 档位三（核显 / MX 级 / 内存仅 8GB）
| 项 | 值 |
|---|---|
| JVM | 用 `launch/jvm-args-low.txt`（-Xmx4G） |
| 渲染距离 | 6-8，模拟距离 4 |
| 画质 | 流畅/普通，关光影 |
| 粒子 | 最少；云关；生物群系过渡关 |
| Embeddium | 开「快速渲染」（默认已开）、防抖勾选 |
| 后台 | 关浏览器，任务管理器结束高占用进程 |

### 通用防卡顿 5 条
1. **绝不分配超过物理内存一半**（8GB 机 → -Xmx4G；16GB 机 → 6-8G）。
2. 中文输入法在游戏内切英文（否则 Forge 崩溃罕见但存在，稳妥起见）。
3. 首次启动建立着色器缓存会卡几秒，属正常；第二次起丝滑。
4. 若内存稳定占用>90% 调低「模拟距离」优先于「渲染距离」。
5. 笔记本务必插电并开启独显（NVIDIA 控制面板 → 程序设置 → javaw.exe → 高性能显卡）。

---

## 5. 常见问题速查

| 现象 | 处理 |
|---|---|
| 启动即闪退、日志有 `Exception loading ... kubejs` | 报错信息发我；绝大多数是版本/环境差异 |
| 世界创建后 `starciv:rustfall` 无法 `/execute in` | 数据包未启用——在创建世界界面勾选（见 1.4） |
| 联机进不去服务器 | 客户端模组与服务器不一致；关防火墙 25565 端口 |
| 提示缺 Java | 装 [Temurin 17](https://adoptium.net/temurin/releases/?version=17) 64 位 |
| PCL2 导入 zip 报「缺少版本」 | 用 `build_pcl_pack.ps1` 的完整 zip（内含 versions/） |
| 想用 HMCL/HMCL 不支持 zip | HMCL → 版本列表 → 安装 Forge 1.20.1 → 把本包 `mods/` 与数据包/资源包拷入其游戏目录 |
| 帧数低但 CPU/GPU 占用不高 | 检查是否核显在跑：全局强制独显（见 4） |

> 任何错误日志：`logs/latest.log`（客户端）或 `server/logs/latest.log`（服务端），附带发给我们即可秒定位。