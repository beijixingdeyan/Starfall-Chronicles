# =============================================================
# Starfall Chronicles — 主菜单标题大 LOGO 生成器
# 产出: resourcepacks/starciv_resources/assets/minecraft/textures/gui/title/
#   minecraft.png  (1024x256)  主菜单大字 → 金色艺术字 "STARFALL" + "CHRONICLES"
#   edition.png    (512x64)    主菜单小字 → "星际编年史 · Forge Edition"
# 用法: pwsh ./scripts/make_title_logo.ps1
# =============================================================
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
$outDir = '.\pack\.minecraft\resourcepacks\starciv_resources\assets\minecraft\textures\gui\title'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function New-TextLogo([System.Drawing.Bitmap]$bmp, [string]$main, [string]$sub, [int]$mainSize, [int]$subSize, [string]$fontName, [int]$yOffset) {
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $g.TextRenderingHint = 'AntiAliasGridFit'
  $fam = New-Object System.Drawing.FontFamily($fontName)
  $W = $bmp.Width
  # ---- 主标题（STARFALL）：描边 + 金色渐变 + 高光 ----
  $fmt = New-Object System.Drawing.StringFormat
  $fmt.Alignment = 'Center'
  $fmt.LineAlignment = 'Center'
  $mainRect = New-Object System.Drawing.RectangleF(0, ($yOffset - $mainSize * 0.55), $W, ($mainSize * 1.35))
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddString($main, $fam, 700, $mainSize, $mainRect, $fmt)  # style: 700 = Bold
  # 黑色粗描边（外）
  $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 10, 12, 20), ($mainSize * 0.10))
  $pen.LineJoin = 'Round'
  $g.DrawPath($pen, $path)
  # 深金描边（内）
  $pen2 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 60, 42, 8), ($mainSize * 0.045))
  $pen2.LineJoin = 'Round'
  $g.DrawPath($pen2, $path)
  # 金色渐变填充
  $rect = $path.GetBounds()
  $lg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, [System.Drawing.Color]::FromArgb(255, 248, 214, 120), [System.Drawing.Color]::FromArgb(255, 150, 92, 16), 90)
  $g.FillPath($lg, $path)
  # 顶部高光（浅金半透明白，上移一条）
  $g.TranslateTransform(0, -$mainSize * 0.05)
  $hl = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, [System.Drawing.Color]::FromArgb(160, 255, 244, 196), [System.Drawing.Color]::FromArgb(10, 255, 244, 196), 90)
  $g.FillPath($hl, $path)
  $g.ResetTransform()
  # ---- 副标题（CHRONICLES）：白色发光字 ----
  if ($sub) {
    $subRect = New-Object System.Drawing.RectangleF(0, ($yOffset + $mainSize * 0.42), $W, ($subSize * 1.6))
    $spath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $spath.AddString($sub, $fam, 400, $subSize, $subRect, $fmt)
    $spen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 8, 10, 16), ($subSize * 0.12))
    $spen.LineJoin = 'Round'
    $g.DrawPath($spen, $spath)
    $srect = $spath.GetBounds()
    $slg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($srect, [System.Drawing.Color]::FromArgb(255, 235, 240, 250), [System.Drawing.Color]::FromArgb(255, 110, 130, 160), 90)
    $g.FillPath($slg, $spath)
    $spen.Dispose(); $slg.Dispose()
  }
  $path.Dispose(); $pen.Dispose(); $pen2.Dispose(); $lg.Dispose(); $hl.Dispose(); $g.Dispose()
  return $bmp
}

# ---- 主标题 1024x256 ----
$bmp = New-Object System.Drawing.Bitmap(1024, 256)
New-TextLogo $bmp 'STARFALL' 'CHRONICLES' 150 64 'Arial Black' 34
$t1 = Join-Path $outDir 'minecraft.png'
$bmp.Save($t1, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host ("生成 " + $t1)

# ---- 小字 512x64（中文版本条）----
$bmp2 = New-Object System.Drawing.Bitmap(512, 64)
$g2 = [System.Drawing.Graphics]::FromImage($bmp2)
$g2.SmoothingMode = 'AntiAlias'
$g2.TextRenderingHint = 'AntiAliasGridFit'
# 金色小字：星际编年史 · Forge Edition
$fmt2 = New-Object System.Drawing.StringFormat
$fmt2.Alignment = 'Center'
$fmt2.LineAlignment = 'Center'
$fam2 = New-Object System.Drawing.FontFamily('Microsoft YaHei')
$r2 = New-Object System.Drawing.RectangleF(0, 6, 512, 40)
$p2 = New-Object System.Drawing.Drawing2D.GraphicsPath
$p2.AddString('星际编年史 · Forge Edition', $fam2, 400, 30, $r2, $fmt2)
$pen2b = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 6, 8, 12), 6)
$pen2b.LineJoin = 'Round'
$g2.DrawPath($pen2b, $p2)
$r2f = $p2.GetBounds()
$lg2 = New-Object System.Drawing.Drawing2D.LinearGradientBrush($r2f, [System.Drawing.Color]::FromArgb(255, 246, 210, 118), [System.Drawing.Color]::FromArgb(255, 148, 90, 14), 90)
$g2.FillPath($lg2, $p2)
$t2 = Join-Path $outDir 'edition.png'
$bmp2.Save($t2, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp2.Dispose()
Write-Host ("生成 " + $t2)
Write-Host "✔ 标题 LOGO 已生成（主菜单显示 Starfall Chronicles，不再显示 Minecraft）"