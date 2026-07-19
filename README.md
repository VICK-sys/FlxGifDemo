# FlxGifDemo

Animated GIF playback in [HaxeFlixel](https://haxeflixel.com/) with a drag-and-drop asset workflow. Drop any `.gif` into `assets/images`, load it with a `FlxGifSprite`, and build — no manual conversion needed.

## How it works

Playback uses [flxgif](https://github.com/MAJigsaw77/flxgif) (YAGP's GIF player for HaxeFlixel). YAGP hangs or slows down on GIFs with certain frame-delta encodings (common in files from giphy.com and similar), so this project adds a prebuild hook that normalizes every GIF in `assets/` through FFmpeg before each build:

- `tools/normalize-gifs.ps1` runs automatically via the `<prebuild>` tag in `Project.xml`
- Each GIF is re-encoded at full resolution with a single global palette (`palettegen`/`paletteuse`)
- An MD5 cache (`gif_cache.json`) skips files that are already normalized, so incremental builds stay fast

A 480×312, 82-frame GIF that previously never finished decoding loads in ~360ms after normalization.

## Requirements

- [Haxe](https://haxe.org/) with [HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) 5.x
- `haxelib install flxgif`
- [FFmpeg](https://ffmpeg.org/) on PATH (used by the prebuild hook)
- Windows (the prebuild hook is a PowerShell script)

## Usage

```haxe
import flxgif.FlxGifSprite;

var gif = new FlxGifSprite(0, 0);
gif.loadGif("assets/images/giphy.gif");
gif.screenCenter();
add(gif);
```

Build and run:

```
lime test html5
```

Note: the prebuild hook rewrites GIFs in `assets/` in place (re-quantized palette, visually identical). Keep original copies elsewhere if you need the exact source bytes.
