package;

import flixel.FlxState;

class PlayState extends FlxState
{
	override public function create()
	{
		super.create();

		var gif = new GifSprite(0, 0, AssetPaths.giphy__gif);
		gif.antialiasing = true;
		gif.screenCenter();
		add(gif);
	}
}
