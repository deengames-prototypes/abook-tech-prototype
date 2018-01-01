package deengames.abook.boot;

import flixel.FlxG;
import deengames.abook.core.Screen;

// Runs after preloader.
// Loads JSON, sets up screens, goes to splash screen
class StartupScreen extends Screen {

  override public function create() : Void
  {
    // Load Game.json file
    // Parse and create screens
    // Populate them into Screen.screens
    var json = openfl.Assets.getText('assets/Game.json');
    deengames.abook.ScreensJsonParser.parse(json);
    FlxG.switchState(new deengames.abook.boot.SplashScreen());
  }

}
