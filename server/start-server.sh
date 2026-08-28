#!/usr/bin/env bash
# =============================================================
# Starfall Chronicles — Forge 服务端一键启动（Linux / macOS）
# 依赖: curl + Java 17 (64-bit, 命令名 java 或 JAVA_HOME 指向 17)
# 用法:
#   ./start-server.sh            # 首次会询问 EULA
#   ./start-server.sh --eula     # 自动接受 EULA
#   ./start-server.sh --sync     # 只同步模组/数据包
# =============================================================
set -euo pipefail
cd "$(dirname "$0")"
ForgeVer="1.20.1-47.4.23"
MCVer="1.20.1"
InstallerUrl="https://maven.minecraftforge.net/net/minecraftforge/forge/$ForgeVer/forge-$ForgeVer-installer.jar"

EULA=0; SYNC=0
for a in "$@"; do
  case "$a" in
    --eula) EULA=1 ;;
    --sync) SYNC=1 ;;
    *) echo "未知参数: $a" >&2; exit 2 ;;
  esac
done

# ---- Java 17 检测 ----
if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/java" ]; then JAVA="$JAVA_HOME/bin/java"; else JAVA="java"; fi
JMAJOR="$("$JAVA" -version 2>&1 | head -n1 | sed -E 's/.*version "([0-9]+).*/\1/')"
if [ "$JMAJOR" != "17" ]; then echo "需要 Java 17 (64-bit)。请安装: https://adoptium.net/temurin/releases/?version=17" >&2; exit 1; fi
echo "Java 17 OK: $JAVA"

# ---- Forge 服务端安装 ----
if [ ! -d libraries ]; then
  echo "== 下载 Forge $ForgeVer 服务端安装器 =="
  curl -fsSL -o "forge-$ForgeVer-installer.jar" "$InstallerUrl"
  echo "== 安装 Forge 服务端 =="
  "$JAVA" -jar "forge-$ForgeVer-installer.jar" --installServer .
  rm -f "forge-$ForgeVer-installer.jar"
fi

# ---- EULA ----
if [ ! -f eula.txt ]; then
  if [ "$EULA" -eq 0 ]; then
    read -r -p "接受 Minecraft EULA（https://aka.ms/MinecraftEULA）？输入 y 继续: " ans
    [ "$ans" = "y" ] || { echo "已取消"; exit 0; }
  fi
  echo "eula=true" > eula.txt
  echo "已写入 eula.txt"
fi

# ---- 同步模组 ----
# 纯客户端模组（光影/渲染）不能进服务端，否则 Forge 直接致命失败
SRC="../pack/.minecraft/mods"
CLIENT_ONLY_PREFIX="oculus-"
if [ -d "$SRC" ]; then
  mkdir -p mods
  rm -f mods/*.jar
  SKIPPED=""
  COUNT=0
  for f in "$SRC"/*.jar; do
    case "$(basename "$f")" in
      "$CLIENT_ONLY_PREFIX"*) SKIPPED="$SKIPPED $(basename "$f")" ;;
      *) cp -f "$f" mods/ && COUNT=$((COUNT+1)) ;;
    esac
  done
  echo "模组同步完成: $COUNT 个 jar${SKIPPED:+（跳过纯客户端: $SKIPPED）}"
else
  echo "警告: $SRC 不存在，请先运行 scripts/install_mods.sh" >&2
fi

# ---- 数据包 ----
DP_SRC="../pack/.minecraft/datapacks/starciv_dp"
if [ -d "$DP_SRC" ] && [ -d world ]; then
  mkdir -p world/datapacks
  rm -rf world/datapacks/starciv_dp
  cp -r "$DP_SRC" world/datapacks/starciv_dp
  echo "数据包已放入 world/datapacks/starciv_dp"
elif [ -d "$DP_SRC" ]; then
  echo "首次启动：世界未生成。首次结束后再次运行本脚本放置数据包。" >&2
fi

# ---- KubeJS 脚本（必须同步：自定义物品/配方/阶段全部由脚本定义）----
KJS_SRC="../pack/.minecraft/kubejs"
if [ -d "$KJS_SRC" ]; then
  rm -rf kubejs
  cp -r "$KJS_SRC" kubejs
  echo "KubeJS 脚本已同步: kubejs/scripts"
else
  echo "警告: $KJS_SRC 不存在（KubeJS 自定义内容将缺失）" >&2
fi

if [ "$SYNC" -eq 1 ]; then echo "同步完成。"; exit 0; fi

# ---- JVM 参数 ----
if [ -f user_jvm_args.txt.tpl ]; then cp -f user_jvm_args.txt.tpl user_jvm_args.txt
elif [ ! -f user_jvm_args.txt ]; then
  echo '-Xmx6G -Xms2G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1MixedGCCountTarget=4 -XX:SurvivorRatio=32 -XX:+AlwaysPreTouch' > user_jvm_args.txt
fi

ARGS_FILE="libraries/net/minecraftforge/forge/$ForgeVer/unix_args.txt"
[ -f "$ARGS_FILE" ] || { echo "找不到 $ARGS_FILE" >&2; exit 1; }
echo "== 启动 Starfall Chronicles 服务端（MC $MCVer / Forge $ForgeVer）=="
"$JAVA" @user_jvm_args.txt "@$ARGS_FILE" nogui
echo "服务端已停止。"