# =============================================================
# Starfall Chronicles — 纹理生成器（纯 PowerShell，无第三方依赖）
# 生成 16x16 物品/方块纹理与 128x128 资源包图标（PNG, RGBA）。
# 输出: pack/.minecraft/resourcepacks/starciv_resources/assets/starciv/textures/
# 用法: pwsh ./scripts/build_textures.ps1
# =============================================================
$ErrorActionPreference = 'Stop'

$outRoot = Join-Path $PSScriptRoot '..\pack\.minecraft\resourcepacks\starciv_resources\assets\starciv\textures'
New-Item -ItemType Directory -Force -Path (Join-Path $outRoot 'item'), (Join-Path $outRoot 'block') | Out-Null

# ---------- 极小 PNG 编码器 ----------
function Get-Crc32Table {
    $t = New-Object 'int64[]' 256
    for ($n = 0; $n -lt 256; $n++) {
        $c = [int64]$n
        for ($k = 0; $k -lt 8; $k++) {
            if (($c -band 1) -ne 0) { $c = ([int64]0xEDB88320) -bxor ($c -shr 1) } else { $c = $c -shr 1 }
        }
        $t[$n] = $c
    }
    return ,$t
}
$crcTable = Get-Crc32Table
function Get-Crc32([byte[]]$data) {
    $c = [int64]-1
    foreach ($b in $data) {
        $idx = ($c -bxor $b) -band 0xFF
        $c = $crcTable[$idx] -bxor ($c -shr 8)
    }
    return (-bnot $c)
}
function Get-Adler32([byte[]]$data) {
    $a = [int64]1; $b = [int64]0
    foreach ($x in $data) { $a = ($a + $x) % 65521; $b = ($b + $a) % 65521 }
    return (($b -shl 16) -bor $a)
}
function Push-UInt32BE([System.IO.MemoryStream]$ms, [int64]$v) {
    $v = $v -band ([int64]0xFFFFFFFF)
    $ms.WriteByte([byte](($v -shr 24) -band 0xFF))
    $ms.WriteByte([byte](($v -shr 16) -band 0xFF))
    $ms.WriteByte([byte](($v -shr 8) -band 0xFF))
    $ms.WriteByte([byte]($v -band 0xFF))
}
function Push-Chunk([System.IO.MemoryStream]$ms, [string]$type, [byte[]]$data) {
    Push-UInt32BE $ms ([int64]$data.Length)
    $typeBytes = [Text.Encoding]::ASCII.GetBytes($type)
    $ms.Write($typeBytes, 0, 4)
    $ms.Write($data, 0, $data.Length)
    $crcBuf = New-Object byte[] ($data.Length + 4)
    [Array]::Copy($typeBytes, 0, $crcBuf, 0, 4)
    [Array]::Copy($data, 0, $crcBuf, 4, $data.Length)
    Push-UInt32BE $ms ([int64](Get-Crc32 $crcBuf))
}
function New-StoredDeflate([byte[]]$raw) {
    # zlib(no compression) + stored deflate blocks (supports >65535 via multi-block) + adler32
    $ms = New-Object System.IO.MemoryStream
    $ms.WriteByte(0x78); $ms.WriteByte(0x01)
    $off = 0
    while ($off -lt $raw.Length) {
        $n = [Math]::Min(65535, $raw.Length - $off)
        $final = if (($off + $n) -ge $raw.Length) { 1 } else { 0 }
        $ms.WriteByte([byte]$final) # BFINAL, BTYPE=00
        $ms.WriteByte([byte]($n -band 0xFF))
        $ms.WriteByte([byte](($n -shr 8) -band 0xFF))
        $nl = ($n -bxor 0xFFFF) -band 0xFFFF
        $ms.WriteByte([byte]($nl -band 0xFF))
        $ms.WriteByte([byte](($nl -shr 8) -band 0xFF))
        $ms.Write($raw, $off, $n)
        $off += $n
    }
    Push-UInt32BE $ms ([int64](Get-Adler32 $raw))
    return $ms.ToArray()
}
function New-Png([int]$w, [int]$h, [byte[]]$rgba, [string]$outPath) {
    $ms = New-Object System.IO.MemoryStream
    $ms.Write([byte[]](0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A), 0, 8)
    # IHDR
    $ihdr = New-Object byte[] 13
    $ihdr[0] = [byte](($w -shr 24) -band 0xFF); $ihdr[1] = [byte](($w -shr 16) -band 0xFF)
    $ihdr[2] = [byte](($w -shr 8) -band 0xFF);  $ihdr[3] = [byte]($w -band 0xFF)
    $ihdr[4] = [byte](($h -shr 24) -band 0xFF); $ihdr[5] = [byte](($h -shr 16) -band 0xFF)
    $ihdr[6] = [byte](($h -shr 8) -band 0xFF);  $ihdr[7] = [byte]($h -band 0xFF)
    $ihdr[8] = 8   # bit depth
    $ihdr[9] = 6   # color type RGBA
    $ihdr[10] = 0; $ihdr[11] = 0; $ihdr[12] = 0
    Push-Chunk $ms 'IHDR' $ihdr
    # scanlines: filter 0 per row
    $raw = New-Object System.IO.MemoryStream
    for ($y = 0; $y -lt $h; $y++) {
        $raw.WriteByte(0)
        $raw.Write($rgba, $y * $w * 4, $w * 4)
    }
    Push-Chunk $ms 'IDAT' (New-StoredDeflate $raw.ToArray())
    Push-Chunk $ms 'IEND' ([byte[]]@())
    [IO.File]::WriteAllBytes($outPath, $ms.ToArray())
}

# ---------- 像素工具 ----------
function New-Canvas([int]$w, [int]$h, [byte[]]$bg) {
    $buf = New-Object byte[] ($w * $h * 4)
    for ($i = 0; $i -lt $buf.Length; $i += 4) {
        $buf[$i] = $bg[0]; $buf[$i+1] = $bg[1]; $buf[$i+2] = $bg[2]; $buf[$i+3] = $bg[3]
    }
    return ,$buf
}
function Set-Px([byte[]]$buf, [int]$w, [int]$x, [int]$y, [int]$r, [int]$g, [int]$b, [int]$a) {
    if ($x -lt 0 -or $y -lt 0 -or $x -ge $w -or $y -ge ([int]($buf.Length / ($w * 4)))) { return }
    $i = ($y * $w + $x) * 4
    $buf[$i] = [byte]$r; $buf[$i+1] = [byte]$g; $buf[$i+2] = [byte]$b; $buf[$i+3] = [byte]$a
}
function Fill-Rect([byte[]]$buf, [int]$w, [int]$x1, [int]$y1, [int]$x2, [int]$y2, [int]$r, [int]$g, [int]$b) {
    for ($y = $y1; $y -le $y2; $y++) { for ($x = $x1; $x -le $x2; $x++) { Set-Px $buf $w $x $y $r $g $b 255 } }
}
function Fill-Circle([byte[]]$buf, [int]$w, [int]$cx, [int]$cy, [int]$rad, [int]$r, [int]$g, [int]$b) {
    for ($y = [Math]::Max(0,$cy-$rad); $y -le [Math]::Min(15,$cy+$rad); $y++) {
        for ($x = [Math]::Max(0,$cx-$rad); $x -le [Math]::Min(15,$cx+$rad); $x++) {
            $dx = $x - $cx; $dy = $y - $cy
            if ($dx*$dx + $dy*$dy -le $rad*$rad) { Set-Px $buf $w $x $y $r $g $b 255 }
        }
    }
}
function Fill-Ring([byte[]]$buf, [int]$w, [int]$cx, [int]$cy, [int]$rOuter, [int]$rInner, [int]$r, [int]$g, [int]$b) {
    for ($y = [Math]::Max(0,$cy-$rOuter); $y -le [Math]::Min(15,$cy+$rOuter); $y++) {
        for ($x = [Math]::Max(0,$cx-$rOuter); $x -le [Math]::Min(15,$cx+$rOuter); $x++) {
            $dx = $x - $cx; $dy = $y - $cy; $d2 = $dx*$dx + $dy*$dy
            if ($d2 -le $rOuter*$rOuter -and $d2 -ge $rInner*$rInner) { Set-Px $buf $w $x $y $r $g $b 255 }
        }
    }
}
function Add-Noise([byte[]]$buf, [int]$w, [int]$seed, [int]$count, [int]$r, [int]$g, [int]$b, [int]$a) {
    $s = $seed
    for ($i = 0; $i -lt $count; $i++) {
        $s = (($s * 1103515245 + 12345) -band 0x7FFFFFFF)
        $x = $s % $w
        $s = (($s * 1103515245 + 12345) -band 0x7FFFFFFF)
        $y = $s % 16
        Set-Px $buf $w $x $y $r $g $b $a
    }
}

# ---------- 定义纹理 ----------
function New-ItemTexture([int]$seed, [byte[]]$bg, [scriptblock]$draw, [string]$name) {
    $buf = New-Canvas 16 16 $bg
    & $draw $buf
    Add-Noise $buf 16 $seed 12 255 255 255 22
    New-Png 16 16 $buf (Join-Path $outRoot "item\$name.png")
}
$TG = [byte[]](0x2E,0x5D,0x34,0xFF)   # 深绿
$DG = [byte[]](0x1A,0x1A,0x24,0xFF)   # 暗夜
$GD = [byte[]](0xD4,0xAF,0x37,0xFF)   # 金
$SS = [byte[]](0x8C,0x97,0xA3,0xFF)   # 钢
$CY = [byte[]](0x3B,0xE8,0xFF,0xFF)   # 青
$MG = [byte[]](0xFF,0x4F,0xD8,0xFF)   # 品红
$OR = [byte[]](0xE0,0x7B,0x39,0xFF)   # 橙

$itemDraws = [ordered]@{
    'ancient_seed'  = { param($b) Fill-Circle $b 16 8 8 3 0x6F 0xA8 0x5E; Fill-Circle $b 16 7 7 2 0x9C 0xC6 0x7E; Fill-Circle $b 16 8 6 1 0xE8 0xC7 0x6A }
    'civ_essence'   = { param($b) Fill-Circle $b 16 8 8 4 0x3A 0x33 0x1E; Fill-Circle $b 16 8 8 2 0xD4 0xAF 0x37; Fill-Circle $b 16 8 8 1 0xF7 0xE8 0xA8 }
    'stellar_key'   = { param($b) Fill-Rect $b 16 7 1 8 14 0xB8 0x86 0x0B; Fill-Rect $b 16 2 4 7 9 0xB8 0x86 0x0B; Fill-Rect $b 16 2 4 3 5 0xF3 0xE5 0xAB; Fill-Rect $b 16 2 7 3 8 0xF3 0xE5 0xAB; Fill-Ring $b 16 8 14 1 0 0xE8 0xCE 0x6B }
    'biofuel_canister' = { param($b) Fill-Rect $b 16 3 1 13 14 0x3E 0x7C 0x3A; Fill-Rect $b 16 2 2 14 3 0x9A 0xA0 0xA6; Fill-Rect $b 16 3 8 13 9 0xE0 0x7B 0x39; Fill-Rect $b 16 6 10 10 10 0xFF 0xFF 0xFF }
    'precision_parts' = { param($b) Fill-Rect $b 16 2 3 13 12 0x8C 0x97 0xA3; Fill-Rect $b 16 4 5 11 10 0x5E 0x69 0x74; Fill-Ring $b 16 6 7 2 0 0x3C 0x46 0x50; Fill-Ring $b 16 10 9 2 0 0x3C 0x46 0x50; Fill-Circle $b 16 8 14 1 0xD0 0x33 0x33 }
    'quantum_core'  = { param($b) Fill-Circle $b 16 8 8 6 0x1E 0x16 0x4A; Fill-Circle $b 16 8 8 4 0x7B 0x4C 0xFF; Fill-Circle $b 16 8 8 2 0x3B 0xE8 0xFF; Fill-Circle $b 16 8 8 1 0xE8 0xE8 0xFF }
    'warp_core'     = { param($b) Fill-Circle $b 16 8 8 6 0x2B 0x0B 0x3E; Fill-Ring  $b 16 8 8 5 3 0xFF 0x4F 0xD8; Fill-Ring  $b 16 8 8 2 1 0x3B 0xE8 0xFF; Fill-Circle $b 16 8 8 1 0xFF 0xFF 0xFF }
    'data_slivers'  = { param($b) for ($i = 0; $i -lt 4; $i++) { $x1 = 2 + $i*3; $y1 = 14 - $i*3; Fill-Rect $b 16 $x1 $y1 ($x1+2) ($y1+1) 0x29 0xD8 0xE4 } }
    'stargate_core' = { param($b) Fill-Ring $b 16 8 8 7 5 0x3B 0xE8 0xFF; Fill-Ring $b 16 8 8 5 4 0x9F 0xFF 0xFF; Fill-Circle $b 16 8 8 3 0x0A 0x0E 0x1A }
}
foreach ($name in $itemDraws.Keys) {
    $bgc = if ($name -in @('ancient_seed')) { $TG } elseif ($name -in @('biofuel_canister')) { $DG } else { $DG }
    $seed = 0
    foreach ($ch in $name.ToCharArray()) { $seed += [int]$ch }
    New-ItemTexture $seed $bgc $itemDraws[$name] $name
    Write-Host "  texture: $name.png"
}
# 独立绘制 without noise (block)
$bb = New-Canvas 16 16 ([byte[]](0x0A,0x0E,0x1A,0xFF))
& $itemDraws['stargate_core'] $bb
New-Png 16 16 $bb (Join-Path $outRoot "block\stargate_core.png")
Write-Host "  texture: block/stargate_core.png"

# ---------- 128x128 资源包图标（放大同一环图案） ----------
$big = New-Object byte[] (128*128*4)
for ($y = 0; $y -lt 128; $y++) {
  for ($x = 0; $x -lt 128; $x++) {
    $dx = $x - 64; $dy = $y - 64; $d2 = $dx*$dx + $dy*$dy
    $r = 62; $g = 42; $b = 0x12; $a = 0
    if ($d2 -le 62*62 -and $d2 -ge 44*44) { $r = 0x3B; $g = 0xE8; $b = 0xFF; $a = 255 }
    elseif ($d2 -le 44*44 -and $d2 -ge 38*38) { $r = 0x9F; $g = 0xFF; $b = 0xFF; $a = 255 }
    elseif ($d2 -le 38*38) { $r = 0x0A; $g = 0x0E; $b = 0x1A; $a = 255 }
    $i = ($y*128 + $x)*4; $big[$i] = [byte]$r; $big[$i+1] = [byte]$g; $big[$i+2] = [byte]$b; $big[$i+3] = [byte]$a
  }
}
$packIcon = Join-Path $PSScriptRoot '..\pack\.minecraft\resourcepacks\starciv_resources\pack.png'
New-Png 128 128 $big $packIcon
Write-Host "  texture: pack.png (128x128)"
Write-Host "完成: $outRoot"