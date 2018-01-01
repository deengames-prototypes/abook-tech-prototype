package deengames.abook.debug;

import flixel.FlxG;

import deengames.abook.core.Screen;
import deengames.abook.debug.DebugLogger;

// static class
class GameJsonWatcher {
  public static function watchForChanges(relativeFileName:String)
  {
    #if neko
		#if debug
			// Don't watch the file in the bin dir; watch the source one. We get four
			// directories deep from source (export/linux64/neko/bin).
      // TODO: we shouldn't need to do this now that the AssetWatcher is copying
      // over all changed assets files (including Game.json).
			new deengames.io.FileWatcher().watch('../../../../${relativeFileName}')
      .continueOnError().pollTime(0.167) // 60FPS, mmhmm...
      .onChange(function() {
				var currentScreenName = null;
				if (Screen.currentScreenData != null) {
					currentScreenName = Screen.currentScreenData.name;
				}

        // Issue the "lime update neko" command as early as possible, and block
        // until it returns. Note that we're in export/linux64/neko/bin, so we
        // have to specify the Project.xml file location.
        var process = new sys.io.Process("lime", ["update", "../../../../Project.xml", "neko"]);
        // calling exitCode() blocks until the process completes
        var exitCode = process.exitCode();

        var output:haxe.io.Bytes = process.stdout.readAll(); // executes process
        var err:haxe.io.Bytes = process.stderr.readAll();

        var message = 'Reloaded assets. Process exit code is ${exitCode}.';
        if (output.length > 0) {
          message += 'Out is ${output}';
        }
        if (err.length > 0) {
          message += '@@@ err=${err}';
        }
        trace(message);

        process.close();
        // If you are on a scene where you immediately use the new asset (in create()),
        // this can crash. Unless you wait. (There's some race condition, and it's
        // not possible to tell programmatically if the asset was loaded fully.)
        // Well, wait.
        // 0.5s breaks, 0.75s works
        Sys.sleep(0.75);

				var json = sys.io.File.getContent('../../../../${relativeFileName}');
		    deengames.abook.ScreensJsonParser.parse(json);

				var found = false;
				for (data in Screen.screensData) {
					if (data.name == currentScreenName) {
            FlxG.switchState(Screen.createInstance(data));
						found = true;
						break;
					}
				}

				if (!found) {
          DebugLogger.log('Could not find existing screen (name=${currentScreenName}) in ${relativeFileName}. Restarting.');
					var firstScreen = Screen.createInstance(Screen.screensData[0]);
          // Don't just switch screens; note what screen we're on.
          Screen.transitionTo(firstScreen);
				}
			});
      DebugLogger.log("Watching source/assets/Game.json");
		#end
		#end
  }
}
