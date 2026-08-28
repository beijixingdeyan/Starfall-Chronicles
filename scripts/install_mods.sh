#!/usr/bin/env bash
# =============================================================
# Starfall Chronicles — 模组安装器 (bash / Linux-macOS)
# 依赖: curl + jq
# 用法:
#   bash scripts/install_mods.sh                 # required
#   bash scripts/install_mods.sh --optional      # 加装可选模组
#   bash scripts/install_mods.sh --dry-run       # 只列出
# =============================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CFG="$ROOT/scripts/mods.json"
API="https://api.modrinth.com/v2"
UA="starfall-chronicles-installer/1.0 (dsh; github public repo)"

INCLUDE_OPTIONAL=0
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --optional) INCLUDE_OPTIONAL=1 ;;
    --dry-run)  DRY_RUN=1 ;;
    *) echo "未知参数: $arg" >&2; exit 2 ;;
  esac
done

command -v curl >/dev/null || { echo "缺少 curl" >&2; exit 1; }
command -v jq   >/dev/null || { echo "缺少 jq（请安装：https://stedolan.github.io/jq/）" >&2; exit 1; }

MC="$(jq -r '.pack.mc_version' "$CFG")"
LOADER="$(jq -r '.pack.loader' "$CFG")"
INSTALL_DIR="$ROOT/$(jq -r '.pack.install_dir' "$CFG")"
[[ "$DRY_RUN" -eq 0 ]] && mkdir -p "$INSTALL_DIR"

# 收集条目: required 恒装, optional 需显式开启
jq -c '.mods[]' "$CFG" > /tmp/sc_mods.$$.jsonl
if [[ "$INCLUDE_OPTIONAL" -eq 1 ]]; then
  jq -c '.optional_mods[]' "$CFG" >> /tmp/sc_mods.$$.jsonl
fi

echo "== Starfall Chronicles: 解析 MC $MC / $LOADER =="
count=0
while IFS= read -r m; do
  tier="$(jq -r '.tier' <<<"$m")"
  if [[ "$tier" == "optional" && "$INCLUDE_OPTIONAL" -eq 0 ]]; then continue; fi
  slug="$(jq -r '.slug' <<<"$m")"
  url="$API/project/$slug/version?game_versions=%5B%22$MC%22%5D&loaders=%5B%22$LOADER%22%5D"
  if ! body="$(curl -fsSL -H "User-Agent: $UA" "$url")"; then
    echo "  [$slug] API 查询失败" >&2; continue
  fi
  if ! ver="$(jq -r '.[0].version_number // empty' <<<"$body")"; then
    echo "  [$slug] 无 $MC + $LOADER 版本，请去 CurseForge 手动安装" >&2; continue
  fi
  file="$(jq -r '.[0].files[0].filename' <<<"$body")"
  furl="$(jq -r '.[0].files[0].url' <<<"$body")"
  printf "  [%-22s] %-24s -> %s\n" "$slug" "$ver" "$file"
  count=$((count+1))
  if [[ "$DRY_RUN" -eq 0 ]]; then
    dest="$INSTALL_DIR/$file"
    if [[ -f "$dest" ]]; then echo "    跳过(已存在): $file"; continue; fi
    curl -fsSL -H "User-Agent: $UA" -o "$dest" "$furl"
    echo "    OK ($(du -h "$dest" | cut -f1))"
  fi
done < /tmp/sc_mods.$$.jsonl
rm -f /tmp/sc_mods.$$.jsonl

echo ""
echo "== CurseForge 独有模组（请手动下载 jar 放入 mods/）=="
jq -r '.curseforge_only[] | "  * \(.name): \(.page)"' "$CFG"
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[dry-run] 未写入任何文件。"
fi
echo "done."