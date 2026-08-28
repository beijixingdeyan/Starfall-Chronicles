# =============================================================
# Starfall Chronicles — 生成主菜单视觉资源（离线、零版权依赖）
# 产出（写入 starciv_resources 资源包）:
#   textures/gui/title/minecraft.png   1024x256 标题 Logo（替换原版字标）
#   textures/gui/title/edition.png     512x64   副标
#   textures/gui/title/background/panorama_0..5.png  1024x1024 全景
#   texts/splashes.txt                 主菜单标语池
#   pack.png                           资源包图标
# 依赖: Windows 自带 System.Drawing + 中文字体（微软雅黑）
# =============================================================
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root   = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$RpRoot = Join-Path $Root 'pack\.minecraft\resourcepacks\starciv_resources'
$Title  = Join-Path $RpRoot 'assets\minecraft\textures\gui\title'
$Bg     = Join-Path $Title 'background'
$Texts  = Join-Path $RpRoot 'assets\minecraft\texts'
New-Item -ItemType Directory -Force -Path $Bg, $Texts | Out-Null

function New-PlanetBitmap([int]$w, [int]$h, [string]$seed, [string]$planetColor, [bool]$ring) {
  $bmp = New-Object System.Drawing.Bitmap($w, $h)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $g.Clear([System.Drawing.Color]::FromArgb(255, 8, 10, 24))
  # 天际渐变
  $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(0, 0, $w, $h)),
    [System.Drawing.Color]::FromArgb(255, 20, 24, 52),
    [System.Drawing.Color]::FromArgb(255, 6, 6, 16),
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
  $g.FillRectangle($grad, 0, 0, $w, $h)
  $grad.Dispose()
  # 星野
  $rnd = New-Object System.Random([int]$seed.GetHashCode())
  for ($i = 0; $i -lt 620; $i++) {
    $x = $rnd.Next(0, $w); $y = $rnd.Next(0, $h)
    $a = $rnd.Next(40, 220); $r = $rnd.Next(1, 3)
    $c = if ($rnd.Next(0, 10) -lt 3) { [System.Drawing.Color]::FromArgb($a, 180, 210, 255) } else { [System.Drawing.Color]::FromArgb($a, 255, 255, 255) }
    $pb = New-Object System.Drawing.SolidBrush($c)
    $g.FillEllipse($pb, $x, $y, $r, $r)
    $pb.Dispose()
  }
  # 星云色带（低透明度径向，用水平渐变近似）
  for ($n = 0; $n -lt 3; $n++) {
    $nx = $rnd.Next(0, $w); $ny = $rnd.Next(0, [int]($h * 0.6)); $nr = $rnd.Next(120, 260)
    $rect = New-Object System.Drawing.Rectangle(($nx - $nr), ($ny - $nr), ($nr * 2), ($nr * 2))
    $rg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect,
      [System.Drawing.Color]::FromArgb(26, 120, 60, 200),
      [System.Drawing.Color]::FromArgb(0, 0, 0, 0),
      [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal)
    $g.FillEllipse($rg, $rect)
    $rg.Dispose()
  }
  # 星球
  $px = $rnd.Next([int]($w * 0.2), [int]($w * 0.8)); $py = $rnd.Next([int]($h * 0.25), [int]($h * 0.6))
  $pr = $rnd.Next(60, 130)
  $pcol = [System.Drawing.ColorTranslator]::FromHtml($planetColor)
  $pgrad = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(($px - $pr), ($py - $pr), ($pr * 2), ($pr * 2))),
    [System.Drawing.Color]::FromArgb(255, [Math]::Min(255, $pcol.R + 60), [Math]::Min(255, $pcol.G + 60), [Math]::Min(255, $pcol.B + 60)),
    $pcol, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
  $g.FillEllipse($pgrad, ($px - $pr), ($py - $pr), ($pr * 2), ($pr * 2))
  $pgrad.Dispose()
  # 星球暗面（半月阴影）
  $sha = New-Object System.Drawing.Drawing2D.GraphicsPath
  $sha.AddEllipse(($px - $pr), ($py - $pr), ($pr * 2), ($pr * 2))
  $pb2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(90, 0, 0, 12))
  $g.FillPath($pb2, $sha); $pb2.Dispose(); $sha.Dispose()
  # 光环
  if ($ring) {
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(150, 220, 230, 255), 3)
    $g.DrawEllipse($pen, ($px - $pr * 1.55), ($py - $pr * 0.55), ($pr * 3.1), ($pr * 1.1))
    $pen.Dispose()
  }
  # 大气辉光
  $glow = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 255, 255, 255), 6)
  $g.DrawEllipse($glow, ($px - $pr), ($py - $pr), ($pr * 2), ($pr * 2))
  $glow.Dispose()
  $g.Dispose()
  return $bmp
}

# ---- 1. 全景 6 面（四面星球主题 + 两面通用星空）----
$faces = @(
  @{ name = 'panorama_0.png'; seed = 'valley';    color = '#3FA34D'; ring = $false },
  @{ name = 'panorama_1.png'; seed = 'rust';      color = '#C4552B'; ring = $false },
  @{ name = 'panorama_2.png'; seed = 'silicon';   color = '#9B5DE5'; ring = $true  },
  @{ name = 'panorama_3.png'; seed = 'stellaris'; color = '#2BB7C4'; ring = $false },
  @{ name = 'panorama_4.png'; seed = 'deep1';     color = '#4A6BD6'; ring = $true  },
  @{ name = 'panorama_5.png'; seed = 'deep2';     color = '#D6458F'; ring = $false }
)
foreach ($f in $faces) {
  $bmp = New-PlanetBitmap 1024 1024 $f.seed $f.color $f.ring
  $bmp.Save((Join-Path $Bg $f.name), [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Write-Host ("  全景: " + $f.name + " 已生成")
}

# ---- 2. 标题 Logo（替换原版 minecraft.png，1024x256）----
function New-LogoTitle([string]$out, [string]$mainText, [string]$subText) {
  $w = 1024; $h = 256
  $bmp = New-Object System.Drawing.Bitmap($w, $h)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $g.TextRenderingHint = 'AntiAliasGridFit'
  $g.Clear([System.Drawing.Color]::Transparent)
  $fontMain = New-Object System.Drawing.Font('Microsoft YaHei', 92, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $fontSub  = New-Object System.Drawing.Font('Microsoft YaHei', 20, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  # 文字阴影
  $fmt = New-Object System.Drawing.StringFormat
  $fmt.Alignment = 'Center'; $fmt.LineAlignment = 'Center'
  $rectMain = New-Object System.Drawing.RectangleF(0, 18, $w, 150)
  $rectSub  = New-Object System.Drawing.RectangleF(0, 168, $w, 40)
  $shaBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(140, 0, 0, 0))
  $rectSh1 = New-Object System.Drawing.RectangleF(4, 22, $w, 150)
  $g.DrawString($mainText, $fontMain, $shaBrush, $rectSh1, $fmt)
  # 金色渐变正文
  $gold = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(0, 18, $w, 150)),
    [System.Drawing.Color]::FromArgb(255, 255, 224, 140),
    [System.Drawing.Color]::FromArgb(255, 235, 160, 40),
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
  $g.DrawString($mainText, $fontMain, $gold, $rectMain, $fmt)
  $gold.Dispose()
  # 副标
  $subBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(210, 190, 210, 255))
  $rectSh2 = New-Object System.Drawing.RectangleF(2, 170, $w, 40)
  $g.DrawString($subText, $fontSub, $shaBrush, $rectSh2, $fmt)
  $g.DrawString($subText, $fontSub, $subBrush, $rectSub, $fmt)
  $subBrush.Dispose(); $shaBrush.Dispose(); $fmt.Dispose()
  $fontMain.Dispose(); $fontSub.Dispose(); $g.Dispose()
  $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Write-Host ("  " + $out + " 已生成")
}
New-LogoTitle (Join-Path $Title 'minecraft.png') '星 际 文 明 编 年 史' 'STARFALL CHRONICLES'

# ---- 3. 副标 edition.png（512x64）----
$e = New-Object System.Drawing.Bitmap(512, 64)
$ge = [System.Drawing.Graphics]::FromImage($e)
$ge.SmoothingMode = 'AntiAlias'
$ge.Clear([System.Drawing.Color]::Transparent)
$fe = New-Object System.Drawing.Font('Microsoft YaHei', 17, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bse = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 235, 240, 255))
$fme = New-Object System.Drawing.StringFormat
$fme.Alignment = 'Center'; $fme.LineAlignment = 'Center'
$ge.DrawString('星际文明编年史 · 1.20.1 · Forge', $fe, $bse, (New-Object System.Drawing.RectangleF(0, 0, 512, 64)), $fme)
$fe.Dispose(); $bse.Dispose(); $fme.Dispose(); $ge.Dispose()
$e.Save((Join-Path $Title 'edition.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$e.Dispose()
Write-Host "  edition.png 已生成"

# ---- 4. 标语池 ----
$splashes = @(
  '绿谷的麦田在等你。',
  '四颗星球，四次文明。',
  '种子，是文明的起点。',
  '铁锈星上，浓烟即祝福。',
  '代码即力量——请先备份。',
  '苍穹在物理法则之外。',
  '最原始的，才是最先进的。',
  '一万年前，他们也走到过这里。',
  '污染会反过来吞噬你。',
  '星门钥匙会回应你的阶段。',
  '下一个黎明，属于星辰。',
  '文明从不忘记来路。'
)
[System.IO.File]::WriteAllLines((Join-Path $Texts 'splashes.txt'), $splashes, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "  splashes.txt 已生成 (" + $splashes.Count + " 条)"

# ---- 5. 资源包图标 pack.png（128x128）----
$ic = New-Object System.Drawing.Bitmap(128, 128)
$gi = [System.Drawing.Graphics]::FromImage($ic)
$gi.SmoothingMode = 'AntiAlias'
$gi.Clear([System.Drawing.Color]::FromArgb(255, 10, 12, 28))
# 小徽标：绿色星球 + 金字 S
$ip = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 63, 163, 77))
$gi.FillEllipse($ip, 24, 24, 80, 80); $ip.Dispose()
$iring = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 255, 224, 140), 5)
$gi.DrawEllipse($iring, 14, 44, 100, 40); $iring.Dispose()
$fi = New-Object System.Drawing.Font('Microsoft YaHei', 44, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bi = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 224, 140))
$fmi = New-Object System.Drawing.StringFormat
$fmi.Alignment = 'Center'; $fmi.LineAlignment = 'Center'
$gi.DrawString('S', $fi, $bi, (New-Object System.Drawing.RectangleF(0, 20, 128, 90)), $fmi)
$fi.Dispose(); $bi.Dispose(); $fmi.Dispose(); $gi.Dispose()
$ic.Save((Join-Path $RpRoot 'pack.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$ic.Dispose()
Write-Host "  pack.png 已生成"

Write-Host "✔ 主菜单视觉资源全部生成完毕"