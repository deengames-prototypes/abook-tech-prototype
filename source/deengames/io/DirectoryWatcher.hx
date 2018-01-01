package deengames.io;

import sys.FileSystem;
import sys.io.File;
import haxe.crypto.Sha1;

/** Watch a directory. Use onWatch(...) to register a callback when any file changes. */
class DirectoryWatcher {

  private var directory:String;
  private var callback:Void->Void;
  private var ignoreErrors:Bool = false;
  private var pollIntervalInSeconds:Float = 1;

  // last seen mtime. Null for the first pass (so we don't print out the list of all assets as changed).
  private var lastSeen:Map<String, Date>;

  public function new() {
    #if !neko
      throw "DirectoryWatcher only works in Neko, sorry."
    #end
  }

  public function watch(directory:String) : DirectoryWatcher
  {
    this.directory = directory;

    var t = neko.vm.Thread.create(function() {

      while (true) {
        var reload:Bool = false;
        var map = new Map<String, Date>();

        Sys.sleep(this.pollIntervalInSeconds); // 1s

        var allFiles = readDirectoryRecursively(directory);

        // Check for any changed files, new files, removed files
        for (file in allFiles) {
          var mtime:Date = FileSystem.stat(file).mtime;
          map.set(file, mtime);

          if (this.lastSeen != null) {
            if (this.lastSeen.get(file) == null) {
              trace('New file: ${file}');
              reload = true;
            } else {
              if (lastSeen.get(file).getTime() != mtime.getTime())
              {
                trace('Changed file: ${file}');
                reload = true;
              }
            }
          }
        }

        // Go through files we saw last time, and see if any are missing.
        if (lastSeen != null) {
          for (file in lastSeen.keys())
          {
            if (map.get(file) == null)
            {
              trace('Deleted file: ${file}');
              reload = true;
            }
          }
        }

        if (reload == true) {
          this.lastSeen = map;
          if (this.callback != null) {
            if (this.ignoreErrors) {
              try {
                this.callback();
              } catch (anything:Dynamic) {
                trace('FileWatcher for ${directory} ignored an error: ${anything}');
              }
            } else {
              this.callback();
            }
          }
        }

        if (this.lastSeen == null)
        {
          this.lastSeen = map;          
        }
      }
    });
    return this;
  }

  public function onChange(callback:Void -> Void) : DirectoryWatcher
  {
    this.callback = callback;
    return this;
  }

  public function continueOnError() : DirectoryWatcher
  {
    this.ignoreErrors = true;
    return this;
  }

  public function pollTime(seconds:Float) : DirectoryWatcher
  {
    this.pollIntervalInSeconds = seconds;
    return this;
  }

  private function readDirectoryRecursively(dir:String):Array<String>
  {
    var toReturn = new Array<String>();
    var queue = FileSystem.readDirectory(dir);
    while (queue.length > 0)
    {
      var next = queue.pop();
      if (FileSystem.isDirectory('${dir}/${next}'))
      {
        var nextFiles = readDirectoryRecursively('${dir}/${next}');
        for (file in nextFiles) {
          toReturn.push('${file}');
        }
      }
      else
      {
        toReturn.push('${dir}/${next}');
      }
    }
    return toReturn;
  }
}
