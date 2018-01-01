package deengames.abook.controls;

import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.input.mouse.FlxMouseEventManager;

import deengames.abook.core.Screen;
import deengames.abook.io.SingletonAudioPlayer;

class PlayAudioButton {
  private var buttonSprite:FlxSprite;

  public function new(screen:Screen, audioFile:String) {
    this.buttonSprite = screen.addAndCenter('assets/images/play-sound.png');
    buttonSprite.x = FlxG.width - buttonSprite.width - 32;
    buttonSprite.y = FlxG.height - buttonSprite.height - 32;
    FlxMouseEventManager.add(buttonSprite, null, function(sprite:FlxSprite) {
      this.loadAndPlay(audioFile);
    });
  }

  public function destroy() : Void {
    if (this.buttonSprite != null) {
      this.buttonSprite.destroy();
    }
  }

  public function play(audio:FlxSound) : Void {
    SingletonAudioPlayer.play(audio);    
  }

  /** Uses SingletonAudioPlayer, so it doesn't play at the same time as any elements. */
  public function loadAndPlay(file:String):Void {
    var audio:FlxSound = FlxG.sound.load('${file}${deengames.io.AudioManager.SOUND_EXT}');
    this.play(audio);
  }
  
  public function stopAudio():Void {
    SingletonAudioPlayer.stop();    
  }
}
