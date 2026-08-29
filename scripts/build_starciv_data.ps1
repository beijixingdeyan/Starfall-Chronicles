# 构建 starciv-data 数据 mod（Patchouli 手册的唯一载体）
# 输入：pack/.minecraft/kubejs/data/starciv/patchouli_books（book 源）
# 输出：pack/.minecraft/mods/starciv-data-1.0.0.jar + server/mods/（同名）
# 依赖：JDK17 javac + Forge javafmllanguage jar（编译 @Mod 空类）
# 注意：Patchouli 1.20.1 要求 书内容在 assets/、book.json 在 data/<modId>/，modId 命名空间
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path '.').Path
$outJar = Join-Path $root 'pack\.minecraft\mods\starciv-data-1.0.0.jar'
$bookSrc = Join-Path $root 'pack\.minecraft\kubejs\data\starciv\patchouli_books'
$stg = Join-Path $env:TEMP 'starciv_data_stage'
if (Test-Path $stg) { Remove-Item $stg -Recurse -Force }
New-Item -ItemType Directory -Force -Path $stg | Out-Null
Write-Host "== 1) 数据侧 book.json（data/starciv_data/patchouli_books/handbook/）=="
$hbData = Join-Path $stg 'data\starciv_data\patchouli_books\handbook'
New-Item -ItemType Directory -Force -Path $hbData | Out-Null
Copy-Item (Join-Path $bookSrc 'handbook\book.json') (Join-Path $hbData 'book.json') -Force
Write-Host "== 2) 内容侧 assets（assets/starciv_data/patchouli_books/handbook/en_us/）=="
$hbAssets = Join-Path $stg 'assets\starciv_data\patchouli_books\handbook'
New-Item -ItemType Directory -Force -Path $hbAssets | Out-Null
Copy-Item (Join-Path $bookSrc 'handbook\en_us') (Join-Path $hbAssets 'en_us') -Recurse -Force
Write-Host "== 3) pack.mcmeta（数据包元数据，缺失会导致 pack 不启用）=="
[System.IO.File]::WriteAllText((Join-Path $stg 'pack.mcmeta'), '{"pack":{"pack_format":15,"description":"Starfall Chronicles built-in data"}}', (New-Object System.Text.UTF8Encoding($false)))
Write-Host "== 4) 编译 @Mod 空类 =="
$javafmllang = Get-ChildItem (Join-Path $root 'build_pcl\.minecraft\libraries\net\minecraftforge\javafmllanguage') -Recurse -Filter 'javafmllanguage-1.20.1-47*.jar' -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch 'sources|api' } | Select-Object -First 1
if (-not $javafmllang) { throw '未找到 javafmllanguage jar（先跑 build_pcl_pack.ps1 安装 Forge）' }
$javac = Get-Command javac -ErrorAction SilentlyContinue
if (-not $javac) { $javac = Get-Command (Join-Path $env:JAVA_HOME 'bin\javac.exe') -ErrorAction SilentlyContinue }
if (-not $javac) { throw '未找到 javac（需要 JDK17）' }
$srcDir = Join-Path $env:TEMP 'starfall_mod_src'
New-Item -ItemType Directory -Force -Path $srcDir | Out-Null
[System.IO.File]::WriteAllText((Join-Path $srcDir 'StarcivDataMod.java'), "package starciv.data;`nimport net.minecraftforge.fml.common.Mod;`n@Mod(""starciv_data"")`npublic class StarcivDataMod { public StarcivDataMod() {} }`n", (New-Object System.Text.UTF8Encoding($false)))
$outDir = Join-Path $env:TEMP 'starfall_mod_classes'
if (Test-Path $outDir) { Remove-Item $outDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
& $javac.Source -cp $javafmllang.FullName -d $outDir (Join-Path $srcDir 'StarcivDataMod.java') | Out-Null
if (-not (Test-Path (Join-Path $outDir 'starciv\data\StarcivDataMod.class'))) { throw 'javac 编译失败' }
Write-Host "   @Mod 类编译完成"
Write-Host "== 5) 打包 jar =="
Add-Type -AssemblyName System.IO.Compression
Function Add-ZipDir2([System.IO.Compression.ZipArchive]$zip, [string]$zroot) {
  $seen = New-Object System.Collections.Generic.HashSet[string]
  Get-ChildItem $zroot -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($zroot.Length + 1).Replace('\','/')
    $idx = $rel.LastIndexOf('/')
    if ($idx -gt 0) {
      $p = $rel.Substring(0, $idx)
      while ($p -and $seen.Add($p)) { $null = $zip.CreateEntry($p + '/'); $p2 = $p.LastIndexOf('/'); $p = if ($p2 -gt 0) { $p.Substring(0, $p2) } else { $null } }
    }
    $entry = $zip.CreateEntry($rel)
    $es = $entry.Open()
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    $es.Write($bytes, 0, $bytes.Length)
    $es.Dispose()
  }
}
if (Test-Path $outJar) { Remove-Item $outJar -Force }
$fs = [System.IO.File]::Open($outJar, [System.IO.FileMode]::CreateNew)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
Add-ZipDir2 $zip $stg
Add-ZipDir2 $zip $outDir
$zip.Dispose(); $fs.Dispose()
Add-Type -AssemblyName System.IO.Compression.FileSystem
$chk = [System.IO.Compression.ZipFile]::OpenRead($outJar)
$names = $chk.Entries | ForEach-Object { $_.FullName }
Write-Host ("  jar 条目: " + $names.Count + " | data book.json: " + (@($names | Where-Object { $_ -match '^data/starciv_data/patchouli_books/handbook/book\.json$' }).Count) + " | assets en_us: " + (@($names | Where-Object { $_ -match '^assets/starciv_data/patchouli_books/handbook/en_us/entries/.+\.json$' }).Count) + " | pack.mcmeta: " + (@($names | Where-Object { $_ -eq 'pack.mcmeta' }).Count) + " | Mod.class: " + (@($names | Where-Object { $_ -match '^starciv/data/StarcivDataMod\.class$' }).Count))
$chk.Dispose()
Copy-Item $outJar (Join-Path $root 'server\mods\') -Force
Write-Host ("✔ 已生成: " + $outJar + " (" + [math]::Round((Get-Item $outJar).Length/1KB) + "KB)，并同步 server/mods")