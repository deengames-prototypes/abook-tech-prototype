package deengames.abook.debug;

import flixel.FlxG;

import deengames.abook.core.Screen;
import deengames.abook.debug.DebugLogger;

// static class
class AssetsWatcher {
  public static function watchForChanges(assetsDir:String)
  {
    #if neko
		#if debug
			// Don't watch the file in the bin dir; watch the source one. We get four
			// directories deep from source (export/linux64/neko/bin).
			new deengames.io.DirectoryWatcher().watch('../../../../${assetsDir}')
      .continueOnError().pollTime(1)
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

				var json = sys.io.File.getContent('../../../../${assetsDir}/Game.json');
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
          DebugLogger.log('Could not find existing screen (name=${currentScreenName}) in ${assetsDir}. Restarting.');
					var firstScreen = Screen.createInstance(Screen.screensData[0]);
          // Don't just switch screens; note what screen we're on.
          Screen.transitionTo(firstScreen);
				}
			});
      DebugLogger.log('Watching ${assetsDir}');
		#end
		#end
  }
}
