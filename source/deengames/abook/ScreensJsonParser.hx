package deengames.abook;

import deengames.abook.core.Screen;

// static class
class ScreensJsonParser {
  public static function parse(json:String) : Void
  {
    var gameData:Dynamic = haxe.Json.parse(json);
    var screensData:Array<Dynamic> = cast(gameData.screens, Array<Dynamic>);

    var i = 0;

    // clear existing data
    while (Screen.screensData.length > 0) {
      Screen.screensData.pop();
    }

    for (data in screensData) {
      Screen.screensData.push(data);
    }
  }
}
