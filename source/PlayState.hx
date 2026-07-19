package;

import flixel.FlxState;
import flxgif.FlxGifSprite;

class PlayState extends FlxState
{
	override public function create()
	{
		super.create();

		var gif = new FlxGifSprite(0, 0);
		gif.loadGif("assets/images/giphy.gif");
		gif.antialiasing = true;
		gif.screenCenter();
		add(gif);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
