$root = Split-Path $PSScriptRoot -Parent
$assets = Join-Path $root "assets"
$stage = Join-Path $root ".gifcache\assets"
$cachePath = Join-Path $root ".gifcache\cache.json"

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "normalize-gifs: ffmpeg not found on PATH, cannot normalize gifs"
    exit 1
}

New-Item -ItemType Directory -Force $stage | Out-Null

$cache = @{}
if (Test-Path $cachePath) {
    (Get-Content $cachePath -Raw | ConvertFrom-Json).psobject.properties | ForEach-Object { $cache[$_.Name] = $_.Value }
}

$script:failed = $false
Get-ChildItem $assets -Recurse -Filter *.gif | ForEach-Object {
    $rel = $_.FullName.Substring($assets.Length + 1)
    $outPath = Join-Path $stage $rel
    $hash = (Get-FileHash $_.FullName -Algorithm MD5).Hash
    if ($cache[$rel] -eq $hash -and (Test-Path $outPath)) { return }

    New-Item -ItemType Directory -Force (Split-Path $outPath -Parent) | Out-Null
    ffmpeg -y -loglevel error -i $_.FullName -filter_complex "[0:v]split[a][b];[a]palettegen[p];[b][p]paletteuse=dither=sierra2_4a" -f gif $outPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "normalize-gifs FAILED: $rel"
        if (Test-Path $outPath) { Remove-Item $outPath -Force -Confirm:$false }
        $script:failed = $true
        return
    }
    $cache[$rel] = $hash
    Write-Host "normalized gif: $rel"
}

Get-ChildItem $stage -Recurse -Filter *.gif | ForEach-Object {
    $rel = $_.FullName.Substring($stage.Length + 1)
    if (-not (Test-Path (Join-Path $assets $rel))) {
        Remove-Item $_.FullName -Force -Confirm:$false
        $cache.Remove($rel)
        Write-Host "pruned stale gif: $rel"
    }
}

$cache | ConvertTo-Json | Set-Content $cachePath -Encoding utf8
if ($script:failed) { exit 1 }
