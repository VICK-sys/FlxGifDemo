# FlxGifDemo

A small [HaxeFlixel](https://haxeflixel.com/) project that makes animated GIFs "just work" in your game. Drop a GIF file into the `assets/images` folder, load it with one line of code, and it plays — no converting, no fiddling.

## The problem this solves

HaxeFlixel doesn't play GIFs out of the box. There's a community library ([flxgif](https://github.com/MAJigsaw77/flxgif)) that adds GIF playback, but it has a hidden landmine: GIFs downloaded from sites like Giphy are often saved in a compressed style that the library chokes on. Instead of showing an error, the game just freezes on a black screen forever.

This project fixes that automatically. Every time you build the game, a small script finds all the GIFs in your assets folder and re-saves them with [FFmpeg](https://ffmpeg.org/) (a free video tool) into a plain format the library handles easily. Your original files are never touched — the fixed copies live in a hidden work folder (`.gifcache/`) that the build uses instead. The script remembers which files it already processed, so it only does the work once per file.

To give a sense of the difference: one 5-second Giphy download never finished loading at all in its original form. After the automatic fix-up, the exact same animation loads in about a third of a second.

## Showing a GIF in your game

```haxe
var gif = new GifSprite(0, 0, AssetPaths.giphy__gif);
gif.screenCenter();
add(gif);
```

That's it — the GIF appears and animates. If a GIF is broken and can't be read, you get a small magenta square and a log message instead of a crash, so you can spot the problem and keep working.

If the same GIF is used in several places, the heavy work of unpacking it happens only once and is shared — extra copies are basically free.

### Playback options

A `GifSprite` can be controlled while it plays:

- `speed` — play faster or slower (2 means double speed)
- `paused` — freeze and unfreeze
- `reversed` — play backwards (animation mode only, see below)
- `gifFrame` — jump to a specific frame
- `onLoop` / `onComplete` — run your own code every time the GIF loops, or when a non-looping GIF ends

There are two ways a GIF can be played, and you pick with the last argument when creating the sprite:

- **Normal mode** (default) — frames are drawn one at a time as they're needed. Uses less memory and matches the GIF's exact timing.
- **Animation mode** (`new GifSprite(x, y, path, true)`) — every frame is laid out on one big image up front, and the GIF plays through HaxeFlixel's regular animation system. This unlocks things like reverse playback and works just like animations you'd make from a sprite sheet.

If you show lots of GIFs and worry about memory, `GifCache.clear()` throws away everything that's been unpacked, and `GifCache.enableAutoClear()` does that automatically whenever the game changes screens.

## What you need installed

- [Haxe](https://haxe.org/) with [HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) set up
- The flxgif library: `haxelib install flxgif`
- [FFmpeg](https://ffmpeg.org/) installed and available from the command line
- Windows (the fix-up script is a PowerShell script)

## Running the demo

```
lime test html5
```

The demo shows the same GIF playing in both modes side by side. SPACE pauses, LEFT/RIGHT change speed, R reverses the animation-mode copy.

## Good to know

- The first time you build after adding a **new** GIF, the build fixes it up but doesn't package it yet — build once more and it appears. (Edits to existing GIFs show up right away. This is a quirk of build ordering in the Lime toolchain, not something the script can change.)
- If FFmpeg isn't installed, the build stops with a clear message rather than quietly shipping a GIF that would freeze the game.
- Very long GIFs in animation mode produce a very large frame-sheet image; the game logs a warning if it gets big enough that some graphics cards might refuse it.
