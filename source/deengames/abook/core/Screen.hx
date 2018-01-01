package deengames.abook.core;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.system.FlxSound;

import deengames.io.GestureManager;
import deengames.abook.controls.PlayAudioButton;
import deengames.abook.controls.ChangeScreenButton;
import deengames.abook.io.SingletonAudioPlayer;
import deengames.analytics.FlurryWrapper;
import deengames.analytics.GoogleAnalyticsWrapper;

using deengames.extensions.StringExtensions;

/**
 * The below block is for animated GIFs (yagp)
import com.yagp.GifDecoder;
import com.yagp.Gif;
import com.yagp.GifPlayer;
import com.yagp.GifPlayerWrapper;
import com.yagp.GifRenderer;
import openfl.Assets;
*/

/**
* A common base state used for all screens.
*/
class Screen extends FlxState
{
  /** To maintain statelessness, we keep an array of state data for each screen.
  We don't keep the screen instances, because that could be wierdly stateful.
  (If you want to keep state, use the Reg class, or some other mechanism.)
  We destroy/recreate scenes on demand, using the JSON data. */
  public static var screensData:Array<Dynamic> = new Array<Dynamic>();
  public static var currentScreenData(default, null):Dynamic;
  public static var currentScreen(default, null):Screen;

  public var elements:Array<Element> = new Array<Element>();

  private var nextScreenData:Dynamic;
  private var previousScreenData:Dynamic;
  private var gestureManager:GestureManager = new GestureManager();
  
  private var playAudioButton:PlayAudioButton;
  private var nextButton:ChangeScreenButton;
  private var previousButton:ChangeScreenButton;
  
  private var bgAudio:FlxSound = new FlxSound();

  private var data:Dynamic;

  private static inline var FADE_DURATION_SECONDS = 0.33;

  public function new(?data:Dynamic = null)
  {
    super();
    this.data = data;
  }

  /**
  * Function that is called up when to state is created to set it up.
  */
  override public function create() : Void
  {
    currentScreen = this;
    super.create();
    
    this.gestureManager.onGesture(Gesture.Swipe, onSwipe);

    // Process the JSON data, and create elements, set the background/audio, etc.
    this.processData();

    var next = Screen.getNextScreenData(this);
    if (next != null) {
      this.nextScreenData = next;
      this.nextButton = new ChangeScreenButton(next, true);
      add(this.nextButton);
    }

    var previous = Screen.getPreviousScreenData(this);
    if (previous != null) {
      this.previousScreenData = previous;
      this.previousButton = new ChangeScreenButton(previous, false);
      add(this.previousButton);
    }

    // Fade in
    FlxG.camera.flash(FlxColor.BLACK, FADE_DURATION_SECONDS);
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
    this.gestureManager.update(elapsed);
    super.update(elapsed);
  }

  // Used to start a new session. HaxeFlixel resumes on reopen.
  // Key duplicated in Main.main
  override public function onFocus() : Void
  {
    FlurryWrapper.startSession(Reg.flurryKey);
    GoogleAnalyticsWrapper.init(Reg.googleAnalyticsUrl);
    var name = "Unknown";
    if (this.data != null && this.data.name != null) {
      name = this.data.name;
    }
    FlurryWrapper.logEvent('Resume', { 'Screen': name });
  }

  /**
   * Called on Mobile when the app loses focus / switches out
   * NOTE: this won't fire if FlxG.autoPause = true. The last
   * release that needed this is 3.3.6. If you upgrade, we're cool.
   * See: https://github.com/HaxeFlixel/flixel/issues/1408#issuecomment-67769018
   */
  override public function onFocusLost() : Void
  {
    var name = "Unknown";
    if (this.data != null && this.data.name != null) {
      name = this.data.name;
    }
    FlurryWrapper.logEvent('Shutdown', { 'Final Screen': name });
    FlurryWrapper.endSession();
    super.onFocusLost();
  }
  
  
  
  // Allow sorting by Z (elements have a Z) by removing/re-adding everything.
  public function sortElementsByZ():Void
  {
      for (e in this.elements)
      {
          this.remove(e);
      }
      
      haxe.ds.ArraySort.sort(this.elements, function(e1:Element, e2:Element):Int {
         if (e1.z > e2.z)
         {
             return 1;
         }
         else if (e2.z > e1.z)
         {
             return -1;
         }
         else
         {
             return 0;
         }
      });
      
      for (e in this.elements)
      {
          this.add(e);
      }
      
      // Make sure our next/previous buttons are always on top
      if (this.nextButton != null)
      {
          this.remove(this.nextButton);
          this.add(this.nextButton);
      }
      
      if (this.previousButton != null)
      {
          this.remove(this.previousButton);
          add(this.previousButton);
      }
  }
  
  private function processData() : Void
  {
    // Populate functionality based on data.
    if (this.data != null) {
      if (this.data.backgroundImage != null) {
        this.addAndCenter('assets/images/${this.data.backgroundImage}');
      }
      if (this.data.backgroundAudio != null) {
        this.bgAudio.loadEmbedded('assets/audio/${this.data.backgroundAudio}${deengames.io.AudioManager.SOUND_EXT}', true);
        this.bgAudio.play();
      }

      if (this.data.elements != null) {
        var elements = cast(data.elements, Array<Dynamic>);
        for (element in elements) {
            // Normally, this is an instance of Element. But, if the user specified
            // a custom class, we use that, instead.
            var e:Dynamic;
            if (element.className != null)
            {
                // Create an instance; pass the json snippet for the element to the constructor
                e = Type.createInstance(Type.resolveClass(element.className), [element]);
            }
            else
            {
                e = new Element();    
            }
            
            Element.populateFromData(element, e);
            add(e);
            
            if (Std.is(e, Element))
            {
                this.elements.push(e);
                e.create();
            }            
        }
      }

      // Audio button last, so it draws on top of all elements
      if (this.data.audio != null) {
        this.loadAndPlay('assets/audio/${this.data.audio}');
      }
      if (this.data.hideAudioButton == true) {
        this.hideAudioButton();
      }
      
      this.sortElementsByZ();
    }    
  }

  // Returns the data for the next sceen (which is enough to construct it)
  private static function getNextScreenData(screen:Screen) : Dynamic
  {
    var datas = Screen.screensData;
    var arrayIndex = datas.indexOf(screen.data);
    if (arrayIndex > -1 && arrayIndex < datas.length - 1) {
      // Return the first screen with show != false
      for (i in (arrayIndex + 1)...datas.length) {
        if (datas[i].show != false) {
          return datas[i];
        }
      }
      // The rest are all show = false. There's no screen.
      return null;
    } else {
      return null;
    }
  }

  // Returns the data for the previous sceen (which is enough to construct it)
  private static function getPreviousScreenData(screen:Screen) : Dynamic
  {
    var datas = Screen.screensData;
    var arrayIndex = datas.indexOf(screen.data);
    if (arrayIndex > 0) {
      // Return the first screen with show != false
      var i = arrayIndex - 1;
      while (i >= 0) {
        if (datas[i].show != false) {
          return datas[i];
        }
        i -= 1;
      }
      // The rest are all show = false. There's no screen.
      return null;
    } else {
      return null;
    }
  }

  public function addAndCenter(fileName:String) : FlxSprite
  {
    fileName = fileName.addExtension();
    var sprite = this.addSprite(fileName);
    centerOnScreen(sprite);
    return sprite;
  }
  
  public function stopAudio():Void
  {
    if (this.playAudioButton != null)
    {
        this.playAudioButton.stopAudio();
    }
  }
  
  public static function createInstance(screenData:Dynamic) : Screen
  {
    if (screenData != null && screenData.className != null) {
      // Create the specified type. Must have a constructor with no args.
      var t = Type.resolveClass(screenData.className);
      if (t == null) {
        throw 'Can\'t find instance of custom class ${screenData.className}. Add the "dump" haxeflag and make sure it appears in the output';
      }
      var obj = Type.createInstance(t, [screenData]);
      var screen = cast(obj, Screen);
      return screen;
    } else {
      return new Screen(screenData);
    }
  }

  public static function transitionTo(target:Screen) : Void
  {
    // 1/3s
    FlxG.camera.fade(FlxColor.BLACK, FADE_DURATION_SECONDS, false, function() {
      FlxG.switchState(target);
      currentScreenData = target.data;
    });
  }

  private function addSprite(fileName:String) : FlxSprite
  {
    fileName = fileName.addExtension();
    var sprite = new FlxSprite();
    sprite.loadGraphic(fileName);
    add(sprite);
    return sprite;
  }

  private function addAndCenterAnimation(spriteSheet:String, width:Int, height:Int, frames:Int, fps:Int) : FlxSprite
  {
    spriteSheet = spriteSheet.addExtension();
    var sprite:FlxSprite = new FlxSprite();
    sprite.loadGraphic(spriteSheet, true, width, height);
    var range = [for (i in 0 ... frames) i];
    sprite.animation.add('loop', range, fps, true);
    sprite.animation.play('loop');
    add(sprite);
    centerOnScreen(sprite);
    return sprite;
  }

  // Requires YAGP
  /*
  private function addAndCenterAnimatedGif(file:String) : GifPlayerWrapper {
    var gif:Gif = GifDecoder.parseByteArray(Assets.getBytes(file));
    // Gif is null? Make sure in Project.xml, you specify *.gif as type=binary
    var player:GifPlayer = new GifPlayer(gif);
    var wrapper:GifPlayerWrapper = new GifPlayerWrapper(player);
    FlxG.addChildBelowMouse(wrapper);
    wrapper.x = (FlxG.width - wrapper.width) / 2;
    wrapper.y = (FlxG.height - wrapper.height) / 2;
    // wrapper.scaleX/scaleY
    return wrapper;
  }
  */

  private function scaleToFitNonUniform(sprite:FlxSprite) : Void
  {
    // scale to fit
    var scaleW = FlxG.width / sprite.width;
    var scaleH = FlxG.height / sprite.height;
    //  non-uniform scale
    sprite.scale.set(scaleW, scaleH);
  }

  private function scaleToFit(sprite:FlxSprite) : Void
  {
    var scaleW = FlxG.width / sprite.width;
    var scaleH = FlxG.height / sprite.height;
    var scale = Math.min(scaleW, scaleH);
    //  uniform scale
    sprite.scale.set(scale, scale);
  }

  private function centerOnScreen(sprite:FlxSprite) : Void
  {
    sprite.x = (FlxG.width - sprite.width) / 2;
    sprite.y = (FlxG.height - sprite.height) / 2;
  }

  private function onSwipe(direction:SwipeDirection) : Void
  {
    if (direction == SwipeDirection.Left && this.nextScreenData != null) {
      showNextScreen();
    } else if (direction == SwipeDirection.Right && this.previousScreenData != null) {
      showPreviousScreen();
    }
  }

  private function showNextScreen() : Void
  {
    this.bgAudio.stop();
    logScreen(this.nextScreenData, 'Next');
    var instance = Screen.createInstance(this.nextScreenData);
    Screen.transitionTo(instance);
  }

  private function showPreviousScreen() : Void
  {
    this.bgAudio.stop();
    logScreen(this.previousScreenData, 'Previous');
    var instance = Screen.createInstance(this.previousScreenData);
    Screen.transitionTo(instance);
  }

  /** s = screen data */
  private function logScreen(s:Dynamic, direction:String) {
    FlurryWrapper.logEvent('ShowScreen', { 'Screen': s.name, 'Direction': direction });
  }

  // Called from subclass screens
  private function loadAndPlay(file:String) : Void
  {
    if (this.playAudioButton == null) {
      this.playAudioButton = new PlayAudioButton(this, file);
    }
    this.playAudioButton.loadAndPlay(file);
  }

  private function hideAudioButton() : Void
  {
    if (this.playAudioButton != null) {
      this.playAudioButton.destroy();
    }
  }
}
