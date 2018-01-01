package deengames.extensions;

class StringExtensions {
  /** Given an image file name, adds .png if it doesn't have an extension. */
  public static function addExtension(fileName:String):String
  {
    if (fileName.indexOf('.') == -1) {
      return '${fileName}.png';
    } else {
      return fileName;
    }
  }
}
