package deengames.abook.core;

import deengames.abook.core.onClickCommands.ShowScreenCommand;
import deengames.abook.debug.DebugLogger;
import deengames.abook.io.SingletonAudioPlayer;
using deengames.extensions.StringExtensions;

import flash.filters.ColorMatrixFilter;
import flixel.addons.display.FlxExtendedSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.system.FlxSound;
import flixel.util.FlxSort;
import openfl.geom.Point;

using StringTools;

/**
A basic interactive element, it displays a static image (or the first frame of
an animation). When you click on it, it starts an animation (optional), and plays
an audio file (optional).
**/
class Element extends FlxExtendedSprite
{

  public var animationFile(default, null):String;
  public var imageFile(default, null):String;
  public var scaleTo(default, null):Float = 1.0;
  public var z(default, null):Int = 0;

  private var originalWidth:Float = 0;
  private var originalHeight:Float = 0;
  
  private var pitch:Float = 1.0;
  private var clickAudioFile(default, null):String;
  private var clickAudioSound:FlxSound;
    
  // TODO: a generic interface with .execute() works here too
  private var onClickCommand:ShowScreenCommand;

  public function new(json:Dynamic = null)
  {
    super();
    FlxMouseEventManager.add(this, clickHandler);
  }

  // e is normally an instance of Element. Unless you want to use a custom class.
  public static function populateFromData(data:Dynamic, e:Dynamic):Void
  {    
    if (data.image != null)
    {
      e.setImage('assets/images/${data.image}');
    }
    
    if (data.animation != null)
    {
      var a = data.animation;
      e.setAnimation('assets/images/${a.image}', a.width, a.height, a.frames, a.fps);
    }
    
    if (data.scale != null)
    {
        var raw:String = data.scale;
        // Scale: eg. "50%"
        var stopIndex:Int = raw.indexOf("%");
        if (stopIndex == -1)
        {
            throw '${raw} is not a valid scale percentage; please enter a string like: 33%';
        }
        var scale:String = raw.substring(0, stopIndex);
        var scaleFloat = Std.parseInt(raw) / 100; // 50 => 0.5
        e.scaleTo = scaleFloat;
        e.scaleIfRequired();
        
        e.useHitboxForCollisionDeltection();
    }

    if (data.x != null && data.y != null) {
      var x:Int = data.x;
      var y:Int = data.y;

      if (data.placement != null) {
        var placement:String = data.placement;
        var normalized = placement.replace("-", "").replace(" ", "").toLowerCase();
        if (normalized != "topleft" && normalized != "topright" && normalized != "bottomleft" && normalized != "bottomright" && normalized != "topcenter") {
          DebugLogger.log('Invalid placement value of ${placement}. Valid values are: top-left, top-center, top-right, bottom-left, bottom-right.');
        }
        else 
        {
          if (placement.indexOf('bottom') > -1)
          {
            y = Main.gameHeight - Math.round(e.height) - y;
          }
          
          if (placement.indexOf('center') > -1)
          {
            x = Math.round((Main.gameWidth - e.width) / 2);
          }
          else if (placement.indexOf('right') > -1)
          {
            x = Main.gameWidth - Math.round(e.width) - x;
          }
        }
      }

      e.x = x;
      e.y = y;
    } else if (data.placement != null) {
      DebugLogger.log("Element has placement but no x/y coordinates; please add them: " + data);
    }
    
    if (data.z != null)
    {
        e.z = data.z;
    }
    else
    {
        e.z = 0;
    }
    
    if (data.effect != null)
    {
        e.applyEffect(data.effect);    
    }
        
    if (data.clickAudio != null)
    {
      e.setClickAudio('assets/audio/${data.clickAudio}');
    }

    if (data.onClick != null) {
      var onClick:String = data.onClick;
      // validation
      var normalized = onClick.toLowerCase();
      if (normalized.indexOf('show(') != 0 || normalized.indexOf(')') != normalized.length - 1)
      {
        throw 'Element ${data} has invalid on-click code: ${onClick}. Valid values are: show(screen name)';
      }
      else
      {
        var start = normalized.indexOf('(');
        var stop = normalized.indexOf(')');
        var screenName = onClick.substr(start + 1, stop - start - 1);

        var screenFound = null;
        for (screenData in Screen.screensData)
        {
          if (screenData.name.toLowerCase() == screenName.toLowerCase())
          {
            screenFound = screenData;
          }
        }
        if (screenFound == null)
        {
          throw 'Element ${data} has onClick handler pointing to non-existing screen ${screenName}';
        }
        else
        {
          if (data.animation != null)
          {
            DebugLogger.log('Warning: Element has an animation which will be overridden by the click handler. click=${onClick}, a=${data.animation}, e=${data}');
          }
          e.onClickCommand = new ShowScreenCommand(screenFound);
        }
      }
    }
  }


  public function setImage(imageFile:String) : Void
  {
    this.imageFile = imageFile.addExtension();
    this.loadGraphic(this.imageFile);
    this.originalWidth = this.width;
    this.originalHeight = this.height;
    this.scaleIfRequired();
  }

  /**
  Don't use this with withImage. It overrides the image from withImage. Note that
  the animation resets to the first frame after completion, and restarts on click.
  */
  public function setAnimation(spriteSheet:String, width:Int, height:Int, frames:Int, fps:Int, resetOnCompletion:Bool = true) : Void
  {
    spriteSheet = spriteSheet.addExtension();
    this.animationFile = spriteSheet;
    this.loadGraphic(spriteSheet, true, width, height);
    var range = [for (i in 0 ... frames) i];
    if (resetOnCompletion)
    {
        range.push(0); // reset to first image on completion
    }
    this.animation.add('main', range, fps, false); // false => no loop
    this.scaleIfRequired();
  }

  /**
  Play an animation on click. Note that the audio restarts on click.
  */
  public function setClickAudio(fileName:String) : Void
  {
    this.clickAudioFile = fileName;
    if (this.pitch != 1)
    {
        this.clickAudioSound = FlxG.sound.load('${this.clickAudioFile}-${this.pitch}${deengames.io.AudioManager.SOUND_EXT}');    
    }
    else
    {
        this.clickAudioSound = FlxG.sound.load('${this.clickAudioFile}${deengames.io.AudioManager.SOUND_EXT}');
    }
  }
  
  /**
  Centralizes logic that executes on click.
  */
  public function clickHandler(obj:FlxObject) : Void
  {
    if (this.clickAudioSound != null) {
      // Stop the current screen audio if it's going
      SingletonAudioPlayer.play(this.clickAudioSound);
    }

    if (this.onClickCommand != null) {
      this.onClickCommand.execute();
    } else {
      if (this.animation != null) {
        this.animation.pause();
        this.animation.play('main', true); // force restart
      }
    }
  }
  
  public function setAudioPitch(pitch:Float):Void
  {
      if (this.clickAudioSound == null)
      {
          throw "Element doesn't have audio!";
      }
      
      this.pitch = pitch;
      this.setClickAudio(this.clickAudioFile);
  }
  
  /**
  Called after the object is initialized and fully created. Override it.
  */
  public function create():Void
  {
  }
  
  private function applyEffect(effect:String):Void
  {
      effect = effect.toUpperCase(); 
      if (effect.indexOf("SILHOUETTE") == -1)
      {
          throw 'The effect ${effect} isn\'t implemented.';
      }
      
      var silhouettePercent:Float = 1; // 100% black
      
      // Percent indicated in brackets, eg. silhouette(70)
      if (effect.indexOf('(') > -1)
      {
          var raw = effect.substring(effect.indexOf('(') + 1, effect.indexOf(')'));
          silhouettePercent = (Std.parseInt(raw) / 100); // 70% => 0.7
      }
      
      // Specifying 1 (100% silhouette) gives us a RGB value of 0
      // Specifying 30 (30% silhouette) gives us an RGB value of 0.7
      silhouettePercent = 1 - silhouettePercent;
      
      // Clone the bitmap data; otherwise, it's shared across all instances of this sprite
      var bitmapData = this.graphic.bitmap.clone();
      bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(), new ColorMatrixFilter([
          silhouettePercent, 0, 0, 0, 0,
          0, silhouettePercent, 0, 0, 0,
          0, 0, silhouettePercent, 0, 0,
          0, 0, 0, 1, 0 // identity row
      ]));
      this.graphic.bitmap = bitmapData;
      this.dirty = true;
  }
  
  private function scaleIfRequired():Void
  {
      // Image/animation set; scale (proportionally)
      // Don't use FlxSprite.scale, because performance
      // sucks on Flash. (up to 10x slower!)
      if (this.scaleTo != 1.0)
      {
          this.setGraphicSize(Math.round(this.originalWidth * this.scaleTo), 0);
          this.updateHitbox();
      }
  }
  
  private function useHitboxForCollisionDeltection():Void
  {
      // FlxSprite and FlxExtendedSprite use pixel-perfect collisions, which doesn't include scale
      // If scaled, we use hitbox detection instead. Srsly.
      // See: https://github.com/HaxeFlixel/flixel/issues/1837
      FlxMouseEventManager.remove(this);
      FlxMouseEventManager.add(this, clickHandler, null, null, null, false, true, false);
  }
}
