# FlxGifDemo

Animated GIF playback in [HaxeFlixel](https://haxeflixel.com/) with a drag-and-drop asset workflow. Drop any `.gif` into `assets/images`, load it with a `GifSprite`, and build — no manual conversion needed.

## How it works

Playback uses [flxgif](https://github.com/MAJigsaw77/flxgif)'s YAGP decoder. YAGP hangs or slows down on GIFs with certain frame-delta encodings (common in files from giphy.com and similar), so a prebuild hook normalizes every GIF through FFmpeg before it gets packaged:

- `tools/normalize-gifs.ps1` runs automatically via the `<prebuild>` tag in `Project.xml`
- Source GIFs in `assets/` are never modified; normalized copies are staged in the gitignored `.gifcache/` folder
- Lime packages the staged copies over the original asset paths (`<assets rename>`), so game code just loads `assets/images/whatever.gif`
- An MD5 cache keyed by relative path skips unchanged files, and staged copies of deleted sources are pruned
- A missing FFmpeg or a failed conversion fails the build instead of shipping a GIF that would hang the decoder

One quirk: Lime collects its asset list when it parses `Project.xml`, before the prebuild hook runs. Content changes to existing GIFs are picked up in the same build, but a brand-new GIF file is staged on its first build and packaged starting with the next one — until then it renders as the `GifSprite` placeholder.

A 480×312, 82-frame GIF that never finished decoding raw loads in ~360ms after normalization.

## Runtime

`GifSprite` plays a GIF as a Flixel sprite. Decoded GIF data is shared through `GifCache`, so many sprites (or repeated state switches) parse each file only once. A GIF that fails to decode logs a warning and shows a magenta placeholder instead of crashing the state.

```haxe
var gif = new GifSprite(0, 0, AssetPaths.giphy__gif);
gif.screenCenter();
add(gif);
```

Two playback modes:

- **GifPlayer mode** (default) — YAGP's player composites frames on the fly, honoring per-frame delays exactly.
- **FlxAnimation mode** (`new GifSprite(x, y, path, true)` or `loadGifAsAnimation`) — all frames are rendered once into a grid spritesheet and played through Flixel's animation system, so the full `animation` API works. Frame rate is derived from the average GIF delay (override with the `frameRate` argument). Sheets over 8192px trigger a warning since some GPUs reject them.

Playback controls on both modes:

- `speed` — playback rate multiplier
- `paused` — pause/resume
- `reversed` — reverse playback (FlxAnimation mode only)
- `gifFrame` — read or seek the current frame
- `onLoop` / `onComplete` — `FlxSignal`s for loop and finite-animation end

`GifCache.clear()` frees all decoded GIF memory; `GifCache.enableAutoClear()` does it automatically on every state switch.

## Requirements

- [Haxe](https://haxe.org/) with [HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) 5.x
- `haxelib install flxgif`
- [FFmpeg](https://ffmpeg.org/) on PATH (used by the prebuild hook)
- Windows (the prebuild hook is a PowerShell script)

## Build and run

```
lime test html5
```
