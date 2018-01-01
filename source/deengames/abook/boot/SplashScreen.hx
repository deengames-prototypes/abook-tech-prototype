package deengames.abook.boot;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;

import flixel.FlxGame;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;

import deengames.abook.core.Screen;
import deengames.abook.debug.DebugLogger;
import deengames.io.GestureManager;

// Loads from startup screen.
class SplashScreen extends Screen
{
  private var startTime:Float = 0;

  /**
  * Function that is called up when to state is created to set it up.
  */
  override public function create():Void
  {
    super.create();

    var title:FlxSprite = this.addAndCenter('assets/images/dg-logo');
    this.loadAndPlay('assets/audio/giggle');
    this.hideAudioButton();

    startTime = Date.now().getTime();

    DebugLogger.log("@@@ DEBUG MODE ENABLED @@@");
  }

  /**
  * Function that is called when this state is destroyed - you might want to
  * consider setting all objects this state uses to null to help garbage collection.
  */
  override public function destroy():Void
  {
    super.destroy();
  }

  /**
  * Function that is called once every frame.
  */
  override public function update(elapsed:Float):Void
  {
    // Wait 3s + 0.5s fade-in, then fade out
    if (startTime > 0 && Date.now().getTime() - startTime >= 3500) {
      startTime = 0; // Execute this block only once
      var instance = Screen.createInstance(Screen.screensData[0]);
      Screen.transitionTo(instance);
    }
    super.update(elapsed);
  }

  override private function onSwipe(direction:SwipeDirection) : Void
  {
    // Do nothing. Can't swipe away the splash screen!
  }
}
