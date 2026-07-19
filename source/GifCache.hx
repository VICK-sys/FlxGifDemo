package;

import com.yagp.Gif;
import com.yagp.GifDecoder;
import com.yagp.GifRenderer;
import flixel.FlxG;
import openfl.display.BitmapData;
import openfl.utils.Assets;

class GifCache
{
	static var gifs:Map<String, Gif> = [];
	static var maps:Map<String, GifMap> = [];
	static var autoClearEnabled:Bool = false;

	public static function get(path:String):Null<Gif>
	{
		if (gifs.exists(path))
			return gifs.get(path);

		var gif:Gif = null;
		try
		{
			gif = GifDecoder.parseByteArray(Assets.getBytes(path));
		}
		catch (e:Dynamic)
		{
			FlxG.log.warn('GifCache: failed to decode "$path": $e');
			trace('GifCache: failed to decode "$path": $e');
		}

		if (gif != null)
			gifs.set(path, gif);
		return gif;
	}

	public static function getMap(path:String):Null<GifMap>
	{
		if (maps.exists(path))
			return maps.get(path);

		var gif = get(path);
		if (gif == null)
			return null;

		var n = gif.frames.length;
		var cols = Std.int(Math.ceil(Math.sqrt(n)));
		var rows = Std.int(Math.ceil(n / cols));
		if (gif.width * cols > 8192 || gif.height * rows > 8192)
			FlxG.log.warn('GifCache: spritesheet for "$path" exceeds 8192px, may fail on some GPUs');

		var data = new BitmapData(gif.width * cols, gif.height * rows, true, 0);
		var renderer = new GifRenderer(gif);
		renderer.setTarget(data);
		for (i in 0...n)
			renderer.render(i, (i % cols) * gif.width, Std.int(i / cols) * gif.height);
		renderer.dispose();

		var map:GifMap = {data: data, width: gif.width, height: gif.height, frames: [for (f in gif.frames) f.delay]};
		maps.set(path, map);
		return map;
	}

	public static function enableAutoClear():Void
	{
		if (autoClearEnabled)
			return;
		autoClearEnabled = true;
		FlxG.signals.preStateSwitch.add(clear);
	}

	public static function clear():Void
	{
		for (gif in gifs)
			gif.dispose();
		gifs.clear();

		for (path in maps.keys())
			FlxG.bitmap.removeByKey("gifmap:" + path);
		maps.clear();
	}
}
