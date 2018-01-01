package deengames.io;

import sys.FileSystem;
import sys.io.File;
import haxe.crypto.Sha1;

/** Watch a file. Use onWatch(...) to register a callback when the file changes. */
class FileWatcher {

  private var fileName:String;
  private var callback:Void->Void;
  private var ignoreErrors:Bool = false;
  private var pollIntervalInSeconds:Float = 1;

  public function new() {
    #if !neko
      throw "FileWatcher only works in Neko, sorry."
    #end
  }

  public function watch(fileName:String) : FileWatcher
  {
    this.fileName = fileName;

    var t = neko.vm.Thread.create(function() {

      // The file is small, and file.mtime is not reliable on Linux with Dropbox
      var previousMtime = FileSystem.stat(fileName).mtime.getTime();

      while (true) {
        Sys.sleep(this.pollIntervalInSeconds); // 1s
        var mtime = FileSystem.stat(fileName).mtime.getTime();
        if (previousMtime != mtime) {
          previousMtime = mtime;
          if (this.callback != null) {
            if (this.ignoreErrors) {
              try {
                this.callback();
              } catch (anything:Dynamic) {
                trace('FileWatcher for ${fileName} ignored an error: ${anything}');
              }
            } else {
              this.callback();
            }
          }
        }
      }
    });
    return this;
  }

  public function onChange(callback:Void -> Void) : FileWatcher
  {
    this.callback = callback;
    return this;
  }

  public function continueOnError() : FileWatcher
  {
    this.ignoreErrors = true;
    return this;
  }

  public function pollTime(seconds:Float) : FileWatcher
  {
    this.pollIntervalInSeconds = seconds;
    return this;
  }
}
