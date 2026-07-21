# FlxGifDemo

Animated GIF playback for [HaxeFlixel](https://haxeflixel.com/). Put a GIF in `assets/images`, load it with `GifSprite`, and it plays. GIFs are normalized automatically at build time; no manual conversion is needed.

![Demo: the same GIF playing in both modes](screenshots/demo.gif)

## Background

HaxeFlixel does not play GIFs out of the box. The community library [flxgif](https://github.com/MAJigsaw77/flxgif) adds GIF playback, but its YAGP decoder hangs indefinitely on certain frame-delta encodings, common in files from giphy.com and similar sites. The failure shows as a permanent black screen with no error.

This project works around that with a prebuild step: on every build, `tools/normalize-gifs.ps1` re-encodes each GIF in `assets/` with [FFmpeg](https://ffmpeg.org/) into a plain format the decoder handles. Source files are not modified; the normalized copies are staged in a gitignored `.gifcache/` folder that the build packages instead. An MD5 cache skips files that are already processed.

Measured difference: a 5-second GIF from giphy.com never finished decoding in its original form and decodes in about 360ms after normalization.

## Usage

```haxe
var gif = new GifSprite(0, 0, AssetPaths.giphy__gif);
gif.screenCenter();
add(gif);
```

A file that fails to decode shows a magenta placeholder and logs a warning instead of crashing.

Decoded GIF data is cached and shared: loading the same file multiple times decodes it once.

### Playback properties

- `speed` — playback rate multiplier (clamped to 0.05–10)
- `paused` — pause and resume
- `reversed` — play backwards (animation mode only)
- `gifFrame` — read or set the current frame
- `onLoop` / `onComplete` — signals fired on each loop and when a non-looping GIF ends

Two playback modes, selected with the last constructor argument:

- **Normal mode** (default) — frames are composited on demand. Lower memory use, exact per-frame timing.
- **Animation mode** (`new GifSprite(x, y, path, true)`) — all frames are rendered up front into a sprite sheet and played through HaxeFlixel's animation system. Supports reverse playback and frame scrubbing.

`GifCache.clear()` frees decoded data, and `GifCache.enableAutoClear()` clears automatically on every state switch. Sprites that survive a state switch reload their file on the next update.

## Requirements

- [Haxe](https://haxe.org/) with [HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/)
- The flxgif library: `haxelib install flxgif`
- [FFmpeg](https://ffmpeg.org/) on PATH
- Windows (the prebuild script is PowerShell)

## Demo

```
lime test html5
```

The demo plays the same GIF in both modes side by side. SPACE pauses, LEFT/RIGHT change speed, R reverses the animation-mode copy.

## Notes

- The first build after adding a new GIF stages it but does not package it; it appears on the next build. Edits to existing GIFs apply in the same build. This is Lime build ordering, not something the script can change.
- If FFmpeg is missing or a conversion fails, the build stops with an error naming the file.
- Transparency survives normalization and works in both playback modes.
- Seeking to an earlier frame in normal mode re-composites from frame 0 and is slow; use animation mode for scrubbing.
- Long GIFs in animation mode produce large sprite sheets. A warning is logged past 4096px, the texture size limit of older and mobile GPUs.
- Deleting a GIF removes it from future builds, but a stale copy can remain in `export/` until the next build.
- Normalization re-quantizes the palette. The result is visually identical but not byte-identical; keep originals elsewhere if exact bytes matter.
