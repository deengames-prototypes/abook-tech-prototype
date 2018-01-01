package;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.FlxG;

import deengames.analytics.FlurryWrapper;

class Main extends Sprite
{
	public static var gameWidth:Int = 0; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var gameHeight:Int = 0; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = deengames.abook.boot.StartupScreen; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		gameWidth = 1024;
		gameHeight = 576;

		var json = openfl.Assets.getText('assets/Game.json');
		var game = haxe.Json.parse(json);
		gameWidth = game.width;
		gameHeight = game.height;

		Lib.current.addChild(new Main());
		FlxG.autoPause = false; // Necessary to tap into onFocusLost
		// Duplicated in Screen.onFocus
		FlurryWrapper.startSession(Reg.flurryKey);
		FlurryWrapper.logEvent('New Game');

		// We don't technically need an asset watcher, because we know that whoever
		// changed Game.json will also make asset changes. That works better,
		// because we can't be easily sure if an asset file changed (watching an
		// arbitrary subtree of files is a challenge).
		// deengames.abook.debug.AssetsWatcher.watchForChanges('assets/Game.json');
		deengames.abook.debug.AssetsWatcher.watchForChanges('assets');
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
	}
}
