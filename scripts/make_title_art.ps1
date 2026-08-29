# =============================================================
# Starfall Chronicles — 主菜单全景封面生成器
# 产出: resourcepacks/starciv_resources/assets/minecraft/textures/gui/title/background/panorama_0..5.png
# 视觉: 深空星云 + 四星球(星环巨行星) + 星门巨环 + 城市剪影 —— 华丽而宏大，无任何模组文字/链接
# 用法: pwsh ./scripts/make_title_art.ps1
# =============================================================
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
$outDir = '.\pack\.minecraft\resourcepacks\starciv_resources\assets\minecraft\textures\gui\title\background'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$W = 1024; $H = 1024
$rand = New-Object System.Random(20260829)

function New-Stars([System.Drawing.Bitmap]$bmp) {
  for ($i = 0; $i -lt 420; $i++) {
    $x = $rand.Next(0, $W); $y = $rand.Next(0, [int]($H * 0.8))
    $r = $rand.Next(1, 3)
    $b = $rand.Next(120, 255)
    $c = [System.Drawing.Color]::FromArgb($b, $b, [Math]::Min(255, $b + 20))
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.FillEllipse((New-Object System.Drawing.SolidBrush($c)), $x, $y, $r, $r)
    $g.Dispose()
  }
}

function Add-Planet([System.Drawing.Bitmap]$bmp, [double]$cx, [double]$cy, [double]$rad, [string]$base, [double]$ring, [double]$ringTilt) {
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $col = [System.Drawing.ColorTranslator]::FromHtml($base)
  # 大气光晕
  for ($d = [int]($rad * 1.9); $d -gt [int]$rad; $d -= [int]($rad * 0.12)) {
    $a = [int](36 * (1 - (($d - $rad) / ($rad * 0.9))))
    $glow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($a, $col))
    $g.FillEllipse($glow, [int]($cx - $d), [int]($cy - $d), $d * 2, $d * 2)
    $glow.Dispose()
  }
  # 行星本体（径向明暗）
  $body = New-Object System.Drawing.Drawing2D.GraphicsPath
  $body.AddEllipse([int]($cx - $rad), [int]($cy - $rad), [int]($rad * 2), [int]($rad * 2))
  $pg = New-Object System.Drawing.Drawing2D.PathGradientBrush($body)
  $pg.CenterColor = [System.Drawing.ColorTranslator]::FromHtml($base)
  $pg.CenterPoint = New-Object System.Drawing.PointF ([int]($cx - $rad * 0.4)), ([int]($cy - $rad * 0.4))
  $pg.SurroundColors = @([System.Drawing.Color]::FromArgb(120, 12, 14, 30))
  $g.FillPath($pg, $body)
  # 云带
  for ($i = 0; $i -lt 4; $i++) {
    $yy = $cy - $rad * 0.6 + $i * $rad * 0.4
    $hh = [int]($rad * 0.16)
    $rr = [int]($rad * 0.9)
    for ($k = 0; $k -lt 6; $k++) {
      $xx = $cx - $rr + $rand.Next(-20, 20) + $k * ($rr * 2 / 6)
      $a = $rand.Next(0, 60)
      $sb = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($a, 210, 220, 255))
      $g.FillEllipse($sb, [int]$xx, [int]($yy - $hh / 2), [int]($rr * 0.45), $hh)
      $sb.Dispose()
    }
  }
  # 光环
  if ($ring -gt 0) {
    $pg2 = New-Object System.Drawing.Drawing2D.GraphicsPath
    $pg2.AddEllipse([int]($cx - $ring), [int]($cy - $ring * 0.42), [int]($ring * 2), [int]($ring * 0.84))
    $lb = New-Object System.Drawing.Drawing2D.PathGradientBrush($pg2)
    $lb.CenterColor = [System.Drawing.Color]::FromArgb(110, 245, 235, 200)
    $lb.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 245, 235, 200))
    $g.FillPath($lb, $pg2)
  }
  $pg.Dispose()
  if ($pg2) { $pg2.Dispose() }
  $g.Dispose()
}

function Add-Silhouette([System.Drawing.Bitmap]$bmp, [double]$baseY, [int]$kind) {
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $b = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 10, 14, 24))
  $pts = New-Object System.Collections.Generic.List[System.Drawing.PointF]
  $pts.Add((New-Object System.Drawing.PointF(0, $H)))
  $step = 8
  for ($x = 0; $x -le $W; $x += $step) {
    $n = [Math]::Sin($x * 0.0035 + ($kind * 2)) * 18 + [Math]::Sin($x * 0.011) * 8
    $pts.Add((New-Object System.Drawing.PointF($x, [float]($baseY + $n))))
  }
  $pts.Add((New-Object System.Drawing.PointF($W, $H)))
  $g.FillPolygon($b, @($pts.ToArray()))
  # 星门巨环（前景巨构）
  if ($kind -eq 0) {
    $cx = $W * 0.5; $cy = $H * 0.34; $R = 260
    $pn = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(215, 90, 200, 255), 10)
    $g.DrawArc($pn, [int]($cx - $R), [int]($cy - $R), $R * 2, $R * 2, -30, 240)
    $pn2 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, 120, 230, 255), 22)
    $g.DrawArc($pn2, [int]($cx - $R - 26), [int]($cy - $R - 26), ($R + 52), ($R + 52), -30, 240)
    $pn.Dispose(); $pn2.Dispose()
  }
  $b.Dispose(); $g.Dispose()
}

# 六视角：四星环场景（星球分布随视角变化）
$views = @(
  @{ px = 0.68; py = 0.30; pr = 150; base = '#6fb7e8'; ring = 290; mid = '#c8a2e8'; kind = 0 },
  @{ px = 0.34; py = 0.26; pr = 160; base = '#e08f5a'; ring = 300; mid = '#6fb7e8'; kind = 1 },
  @{ px = 0.62; py = 0.34; pr = 135; base = '#8ac6a8'; ring = 0;    mid = '#e08f5a'; kind = 0 },
  @{ px = 0.30; py = 0.24; pr = 175; base = '#b090e8'; ring = 320; mid = '#6fb7e8'; kind = 1 },
  @{ px = 0.55; py = 0.38; pr = 145; base = '#f0d06a'; ring = 280; mid = '#c8a2e8'; kind = 0 },
  @{ px = 0.72; py = 0.28; pr = 155; base = '#55b0a8'; ring = 0;    mid = '#f0d06a'; kind = 1 }
)
for ($i = 0; $i -lt 6; $i++) {
  $v = $views[$i]
  $bmp = New-Object System.Drawing.Bitmap($W, $H)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  # 天空渐变
  $rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
  $lg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, [System.Drawing.Color]::FromArgb(255, 16, 10, 46), [System.Drawing.Color]::FromArgb(255, 2, 2, 8), 90)
  $g.FillRectangle($lg, $rect)
  $lg.Dispose()
  # 星云带
  $g2 = $g
  for ($k = 0; $k -lt 5; $k++) {
    $nx = $rand.Next(0, $W); $ny = $rand.Next(0, [int]($H * 0.5)); $nr = $rand.Next(90, 220)
    $neb = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($rand.Next(14, 30), $rand.Next(40, 160), $rand.Next(30, 130), $rand.Next(120, 220)))
    $g2.FillEllipse($neb, $nx, $ny, $nr, [int]($nr * 0.5))
    $neb.Dispose()
  }
  $g.Dispose()
  New-Stars $bmp
  Add-Planet $bmp $($v.px * $W) $($v.py * $H) $($v.pr) $($v.base) $($v.ring) 0
  Add-Planet $bmp 120 168 46 $($v.mid) 0 0
  Add-Planet $bmp ($W - 150) 220 36 'silver' 0 0
  Add-Silhouette $bmp ($H * 0.86) $($v.kind)
  # 底部轻微渐隐
  $fg = [System.Drawing.Graphics]::FromImage($bmp)
  $rect2 = New-Object System.Drawing.Rectangle(0, [int]($H * 0.78), $W, [int]($H * 0.22))
  $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect2, [System.Drawing.Color]::FromArgb(0, 0, 0, 0), [System.Drawing.Color]::FromArgb(255, 4, 6, 14), 90)
  $fg.FillRectangle($bg, $rect2)
  $bg.Dispose(); $fg.Dispose()
  $out = Join-Path $outDir ("panorama_" + $i + '.png')
  $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Write-Host ("生成 " + $out)
}
Write-Host "✔ 全景封面已重绘（6 张，星云+四星球+星门巨环，无模组文字）"