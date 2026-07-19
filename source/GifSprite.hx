package;

import com.yagp.GifPlayer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;

class GifSprite extends FlxSprite
{
	public var player(default, null):GifPlayer;
	public var animated(default, null):Bool = false;
	public var speed(default, set):Float = 1;
	public var paused(default, set):Bool = false;
	public var reversed(default, set):Bool = false;
	public var onLoop(default, null):FlxSignal = new FlxSignal();
	public var onComplete(default, null):FlxSignal = new FlxSignal();
	public var gifFrame(get, set):Int;

	var baseFrameRate:Float = 30;
	var lastFrameIndex:Int = 0;

	public function new(?x:Float = 0, ?y:Float = 0, ?path:String, asAnimation:Bool = false)
	{
		super(x, y);
		if (path != null)
		{
			if (asAnimation)
				loadGifAsAnimation(path);
			else
				loadGif(path);
		}
	}

	public function loadGif(path:String):GifSprite
	{
		cleanup();

		var gif = GifCache.get(path);
		if (gif == null)
			return placeholder();

		player = new GifPlayer(gif);
		player.loopEndHandler = onLoop.dispatch;
		player.animationEndHandler = onComplete.dispatch;
		player.playing = !paused;
		loadGraphic(FlxGraphic.fromBitmapData(player.data, false, null, false));
		return this;
	}

	public function loadGifAsAnimation(path:String, ?frameRate:Float):GifSprite
	{
		cleanup();

		var map = GifCache.getMap(path);
		if (map == null)
			return placeholder();

		animated = true;
		loadGraphic(FlxG.bitmap.add(map.data, false, "gifmap:" + path), true, map.width, map.height);

		var total = 0;
		for (delay in map.frames)
			total += delay;
		baseFrameRate = frameRate != null ? frameRate : 1000 * map.frames.length / Math.max(total, 1);

		animation.add("gif", [for (i in 0...map.frames.length) i], baseFrameRate * speed, true);
		animation.play("gif", false, reversed);
		animation.curAnim.paused = paused;
		lastFrameIndex = animation.frameIndex;
		return this;
	}

	override public function update(elapsed:Float):Void
	{
		if (player != null && !paused)
			player.update(elapsed * speed);

		super.update(elapsed);

		if (animated && animation.curAnim != null)
		{
			var cur = animation.frameIndex;
			if ((!reversed && cur < lastFrameIndex) || (reversed && cur > lastFrameIndex))
				onLoop.dispatch();
			lastFrameIndex = cur;
		}
	}

	override public function destroy():Void
	{
		super.destroy();
		cleanup();
		onLoop.removeAll();
		onComplete.removeAll();
	}

	function cleanup():Void
	{
		if (player != null)
		{
			player.dispose();
			player = null;
		}
		animated = false;
	}

	function placeholder():GifSprite
	{
		makeGraphic(32, 32, FlxColor.MAGENTA);
		return this;
	}

	function set_speed(value:Float):Float
	{
		speed = value;
		if (animated && animation.curAnim != null)
			animation.curAnim.frameRate = baseFrameRate * value;
		return value;
	}

	function set_paused(value:Bool):Bool
	{
		paused = value;
		if (player != null)
			player.playing = !value;
		if (animated && animation.curAnim != null)
			animation.curAnim.paused = value;
		return value;
	}

	function set_reversed(value:Bool):Bool
	{
		reversed = value;
		if (animated && animation.curAnim != null)
		{
			animation.play("gif", true, value, animation.frameIndex);
			animation.curAnim.paused = paused;
		}
		return value;
	}

	function get_gifFrame():Int
	{
		if (player != null)
			return player.frame;
		if (animated)
			return animation.frameIndex;
		return 0;
	}

	function set_gifFrame(value:Int):Int
	{
		if (player != null)
			player.frame = value;
		else if (animated)
			animation.frameIndex = value;
		return value;
	}
}
