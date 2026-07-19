$assets = Join-Path $PSScriptRoot "..\assets"
$cachePath = Join-Path $PSScriptRoot "..\gif_cache.json"

$cache = @{}
if (Test-Path $cachePath) {
    (Get-Content $cachePath -Raw | ConvertFrom-Json).psobject.properties | ForEach-Object { $cache[$_.Name] = $_.Value }
}

Get-ChildItem $assets -Recurse -Filter *.gif | ForEach-Object {
    $key = $_.FullName
    $hash = (Get-FileHash $key -Algorithm MD5).Hash
    if ($cache[$key] -eq $hash) { return }

    $tmp = "$key.tmp"
    ffmpeg -y -loglevel error -i $key -filter_complex "[0:v]split[a][b];[a]palettegen[p];[b][p]paletteuse=dither=sierra2_4a" -f gif $tmp
    if ($LASTEXITCODE -eq 0 -and (Test-Path $tmp)) {
        Move-Item -Force $tmp $key
        $cache[$key] = (Get-FileHash $key -Algorithm MD5).Hash
        Write-Host "normalized gif: $($_.Name)"
    }
    else {
        if (Test-Path $tmp) { Remove-Item $tmp -Force -Confirm:$false }
        Write-Host "gif normalize FAILED: $($_.Name)"
    }
}

$cache | ConvertTo-Json | Set-Content $cachePath -Encoding utf8
