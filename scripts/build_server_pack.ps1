# 打包服务端：Starfall-Chronicles 一键开服包
# 输入：server/（已同步 mods/kubejs/config/datapacks）
# 输出：dist/starfall-chronicles-server-<日期>.zip（含 run.bat、eula、开服说明）
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path '.').Path
$src = Join-Path $root 'server'
$date = Get-Date -Format 'yyyyMMdd'
$out = Join-Path $root ("dist\starfall-chronicles-server-" + $date + '.zip')
if (-not (Test-Path $src)) { throw '缺少 server/ 目录（先跑 scripts/sync_server.ps1 或 build_pcl_pack.ps1 同步）' }
New-Item -ItemType Directory -Force -Path (Join-Path $root 'dist') | Out-Null

# ---- 清理运行痕迹 ----
foreach ($p in @('world','crash-reports','logs','backups','usercache.json','banned-ips.json','banned-players.json','ops.json','whitelist.json','latest.log','debug.log')) {
  $t = Join-Path $src $p
  if (Test-Path $t) { Remove-Item $t -Recurse -Force }
}
$staging = Join-Path $env:TEMP 'starfall_server_stage'
if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
New-Item -ItemType Directory -Force -Path $staging | Out-Null
Copy-Item (Join-Path $src '*') $staging -Recurse -Force

# eula / run.bat / README
[System.IO.File]::WriteAllText((Join-Path $staging 'eula.txt'), "eula=true`n", (New-Object System.Text.UTF8Encoding($false)))
$forgeJar = Get-ChildItem $staging -Filter 'forge-*.jar' -ErrorAction SilentlyContinue | Select-Object -First 1
$jarName = if ($forgeJar) { $forgeJar.Name } else { 'forge-1.20.1-47.4.23-universal.jar' }
Write-Host ("检测到 forge: " + $jarName)
[System.IO.File]::WriteAllText((Join-Path $staging 'run.bat'), "@echo off`r`ncd /d %~dp0`r`nchcp 65001 >nul`r`ntitle Starfall Chronicles Server`r`necho [Starfall] 正在启动 Forge 服务端（自动检测 Java17；首次启动会生成世界与地标，请耐心等待 1-3 分钟）...`r`npowershell -NoProfile -ExecutionPolicy Bypass -File `"%~dp0start-server.ps1`" -AcceptEula`r`npause`r`n", (New-Object System.Text.UTF8Encoding($false)))
$readme = @'
==============================================
 Starfall Chronicles（星际文明编年史）服务端
==============================================
【怎么用】
  1. 把本 zip 解压到任意目录（路径不要有中文/空格为宜）
  2. 双击 run.bat（首次启动自动下载式生成世界，约 1-3 分钟）
  3. 看到 "Done" 即开服完成
【客户端怎么连】
  同机：客户端 mc 单人/多人 -> 添加服务器 -> localhost:25565
  局域网/朋友：让对方填 你的IP:25565（路由器开 25565 端口映射）
  无公网 IP：用内网穿透（如 Nukkit/樱花 frp）或 Radmin/蒲公英
【内存】：建议 4G 起（run.bat 里 -Xmx 可改），光影在客户端开即可
【模组/任务/地标】：与单机包完全一致，48 任务 7 页签、四星球、五大地标
【管理】：控制台输入 op <你的ID> 给自己权限；stop 保存并关闭
==============================================
'@
[System.IO.File]::WriteAllText((Join-Path $staging 'README_开服说明.txt'), $readme, (New-Object System.Text.UTF8Encoding($true)))

# ---- 压缩 ----
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
if (Test-Path $out) { Remove-Item $out -Force }
[System.IO.Compression.ZipFile]::CreateFromDirectory($staging, $out, [System.IO.Compression.CompressionLevel]::Optimal, $false)
$z = [System.IO.Compression.ZipFile]::OpenRead($out)
$names = $z.Entries | ForEach-Object { $_.FullName }
Write-Host ("条目: " + $names.Count + " | mods=" + (@($names | Where-Object { $_ -match '^mods/.+\.jar$' }).Count) + " | run.bat=" + (@($names | Where-Object { $_ -eq 'run.bat' }).Count) + " | eula=" + (@($names | Where-Object { $_ -eq 'eula.txt' }).Count) + " | kubejs=" + (@($names | Where-Object { $_ -match '^kubejs/' }).Count))
$z.Dispose()
Remove-Item $staging -Recurse -Force
Write-Host ("✔ 服务端包: " + $out + " " + [math]::Round((Get-Item $out).Length/1MB,1) + "MB")