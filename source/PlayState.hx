package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

class PlayState extends FlxState
{
	var playerGif:GifSprite;
	var animGif:GifSprite;
	var status:FlxText;
	var loops:Int = 0;

	override public function create()
	{
		super.create();
		GifCache.enableAutoClear();

		playerGif = new GifSprite(0, 0, AssetPaths.giphy__gif);
		playerGif.antialiasing = true;
		playerGif.scale.set(0.64, 0.64);
		playerGif.updateHitbox();
		playerGif.setPosition(8, 120);
		add(playerGif);

		animGif = new GifSprite(0, 0, AssetPaths.giphy__gif, true);
		animGif.antialiasing = true;
		animGif.scale.set(0.64, 0.64);
		animGif.updateHitbox();
		animGif.setPosition(324, 120);
		add(animGif);

		animGif.onLoop.add(() -> loops++);

		var left = new FlxText(8, 326, 308, "GifPlayer mode", 12);
		left.alignment = CENTER;
		add(left);

		var right = new FlxText(324, 326, 308, "FlxAnimation mode", 12);
		right.alignment = CENTER;
		add(right);

		status = new FlxText(0, 8, FlxG.width, "", 12);
		status.alignment = CENTER;
		add(status);

		var help = new FlxText(0, 440, FlxG.width, "SPACE pause | LEFT/RIGHT speed | R reverse (animation mode)", 12);
		help.alignment = CENTER;
		add(help);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.SPACE)
		{
			var pause = !playerGif.paused;
			playerGif.paused = pause;
			animGif.paused = pause;
		}

		if (FlxG.keys.justPressed.RIGHT)
			setSpeed(playerGif.speed + 0.25);
		if (FlxG.keys.justPressed.LEFT)
			setSpeed(playerGif.speed - 0.25);
		if (FlxG.keys.justPressed.R)
			animGif.reversed = !animGif.reversed;

		status.text = 'speed x${playerGif.speed}'
			+ (playerGif.paused ? " | paused" : "")
			+ (animGif.reversed ? " | reversed" : "")
			+ ' | loops: $loops';
	}

	function setSpeed(value:Float)
	{
		value = Math.max(0.25, Math.min(4, value));
		playerGif.speed = value;
		animGif.speed = value;
	}
}
