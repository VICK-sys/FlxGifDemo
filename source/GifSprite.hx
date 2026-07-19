package;

import com.yagp.GifPlayer;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;

class GifSprite extends FlxSprite
{
	public var player(default, null):GifPlayer;

	public function new(?x:Float = 0, ?y:Float = 0, ?path:String)
	{
		super(x, y);
		if (path != null)
			loadGif(path);
	}

	public function loadGif(path:String):GifSprite
	{
		if (player != null)
		{
			player.dispose();
			player = null;
		}

		var gif = GifCache.get(path);
		if (gif == null)
		{
			makeGraphic(32, 32, FlxColor.MAGENTA);
			return this;
		}

		player = new GifPlayer(gif);
		loadGraphic(FlxGraphic.fromBitmapData(player.data, false, null, false));
		return this;
	}

	override public function update(elapsed:Float):Void
	{
		if (player != null)
			player.update(elapsed);
		super.update(elapsed);
	}

	override public function destroy():Void
	{
		super.destroy();
		if (player != null)
		{
			player.dispose();
			player = null;
		}
	}
}
