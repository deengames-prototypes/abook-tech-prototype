package deengames.abook.io;

import flixel.system.FlxSound;

// Plays only one file at a time.
class SingletonAudioPlayer {
	
	private static var lastSound:FlxSound;
	
	public static function play(sound:FlxSound) {
		stop();
		lastSound = sound;
		sound.play();
	}
	
	public static function stop() {
		if (lastSound != null) {
			lastSound.stop();
		}
	}
}