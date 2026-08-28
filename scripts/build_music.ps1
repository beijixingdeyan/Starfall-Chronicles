# =============================================================
# Starfall Chronicles — 音乐资源构建
# 产出（写入 starciv_resources 资源包）:
#   assets/minecraft/sounds/starciv/music/menu.ogg   主菜单（CC0 曲目裁剪）
#   assets/minecraft/sounds/starciv/music/drift.ogg  创造模式（合成氛围乐）--待定名
#   assets/minecraft/sounds/starciv/music/echo.ogg   末地/终局（合成氛围乐）
#   assets/minecraft/sounds.json   覆盖 minecraft:music.menu / creative / end
#   CREDITS.txt                   音乐来源与版权声明
# 依赖: downloads/ffmpeg/.../ffmpeg.exe（脚本会自动定位）
# =============================================================
# ffmpeg 会往 stderr 打横幅/进度，PS5.1 在 EAP=Stop 下将其视为终止错误；
# 脚本自身错误用显式 throw / Test-Path 兜底，故此处用 Continue。
$ErrorActionPreference = 'Continue'

$Root   = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$RpRoot = Join-Path $Root 'pack\.minecraft\resourcepacks\starciv_resources'
$MusicD = Join-Path $RpRoot 'assets\minecraft\sounds\starciv\music'
New-Item -ItemType Directory -Force -Path $MusicD | Out-Null

# 定位 ffmpeg
$ff = Get-ChildItem (Join-Path $Root 'downloads\ffmpeg') -Recurse -Filter ffmpeg.exe -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $ff) { throw '未找到 ffmpeg.exe（请先运行下载）' }
$FF = $ff.FullName
Write-Host ("ffmpeg: " + $FF)

$src = Join-Path $Root 'downloads\music\001_Synthwave_4k_0.mp3'
if (-not (Test-Path $src)) { throw '缺少源曲目 001_Synthwave_4k_0.mp3' }

# ---- 1. 主菜单乐：CC0 曲目 0-176s（3 分钟循环友好，末 3s 淡出）----
& $FF -y -i $src -t 176 -af "afade=t=out:st=172:d=4" -c:a libvorbis -q:a 5 -ar 44100 -ac 2 (Join-Path $MusicD 'menu.ogg') 2>&1 | Out-Null
Write-Host ("  menu.ogg: " + [math]::Round((Get-Item (Join-Path $MusicD 'menu.ogg')).Length/1KB) + " KB")

# ---- 2. 创造模式乐「星港低语」：合成氛围 pad（降B大调慢起伏）----
$fc1 = '[0:a]volume=0.55[a0];[1:a]volume=0.35[a1];[a0][a1]amix=inputs=2,tremolo=f=0.15:d=0.7,afade=t=in:st=0:d=6,afade=t=out:st=170:d=6,aecho=0.8:0.7:500:0.3[out]'
& $FF -y -f lavfi -i "sine=frequency=233.08:duration=176" -f lavfi -i "sine=frequency=349.23:duration=176" -filter_complex $fc1 -map "[out]" -c:a libvorbis -q:a 4 -ar 44100 -ac 2 (Join-Path $MusicD 'drift.ogg') 2>&1 | Out-Null
Write-Host ("  drift.ogg: " + [math]::Round((Get-Item (Join-Path $MusicD 'drift.ogg')).Length/1KB) + " KB")

# ---- 3. 终局乐「苍穹回响」：三音叠层立体声 pad（e小调泛音层）----
$fc2 = '[0:a]volume=0.4[a0];[1:a]volume=0.3[a1];[2:a]volume=0.25[a2];[a0][a1][a2]amix=inputs=3,tremolo=f=0.1:d=0.8,afade=t=in:st=0:d=10,afade=t=out:st=166:d=10,aecho=0.7:0.6:400:0.28[out]'
& $FF -y -f lavfi -i "sine=frequency=164.81:duration=176" -f lavfi -i "sine=frequency=246.94:duration=176" -f lavfi -i "sine=frequency=329.63:duration=176" -filter_complex $fc2 -map "[out]" -c:a libvorbis -q:a 4 -ar 44100 -ac 2 (Join-Path $MusicD 'echo.ogg') 2>&1 | Out-Null
Write-Host ("  echo.ogg: " + [math]::Round((Get-Item (Join-Path $MusicD 'echo.ogg')).Length/1KB) + " KB")

# ---- 4. sounds.json：覆盖 vanilla 音乐事件 ----
$soundsJson = @{
  'music.menu' = @{ sounds = @( @{ name = 'starciv:music/menu'; stream = $true } ) }
  'music.creative' = @{ sounds = @( @{ name = 'starciv:music/drift'; stream = $true } ) }
  'music.end' = @{ sounds = @( @{ name = 'starciv:music/echo'; stream = $true } ) }
} | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText((Join-Path $RpRoot 'assets\minecraft\sounds.json'), $soundsJson, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "  sounds.json 已写"

# ---- 5. 版权声明 ----
$credits = @(
  'Starfall Chronicles 音乐版权声明',
  '================================',
  '',
  '1) 主菜单乐(menu.ogg) —— 「Calm Ambient 1 (Synthwave 4k)」',
  '   来源: OpenGameArt (opengameart.org/content/calm-ambient-1-synthwave-4k)',
  '   许可: CC0 1.0 公有领域（原作者放弃版权；本包仅做时长裁剪）',
  '   已注明出处，感谢作者。',
  '',
  '2) drift.ogg / echo.ogg —— 本整合包使用 ffmpeg 合成（正弦叠层+淡入淡出），',
  '   纯算法生成，无采样素材，属公有领域（CC0）。',
  '',
  '3) 其余音频均为 Minecraft 原版音效/音乐，版权归 Mojang 所有。'
)
[System.IO.File]::WriteAllLines((Join-Path $RpRoot 'CREDITS.txt'), $credits, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "  CREDITS.txt 已写"

Write-Host "✔ 音乐资源构建完成"