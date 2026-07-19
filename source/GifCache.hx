package;

import com.yagp.Gif;
import com.yagp.GifDecoder;
import flixel.FlxG;
import openfl.utils.Assets;

class GifCache
{
	static var gifs:Map<String, Gif> = [];

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

	public static function clear():Void
	{
		for (gif in gifs)
			gif.dispose();
		gifs.clear();
	}
}
