package deengames.abook.analytics;

import ru.zzzzzzerg.linden.Flurry;

// A wrapper around Flurry code. Just does Flurry stuff; not abook-specific.
class FlurryWrapper {

  public static function startSession(flurryKey:String) : Void
  {
    Flurry.onStartSession(flurryKey);
  }

  public static function endSession() : Void
  {
    Flurry.onEndSession();
  }

  public static function logEvent(name:String, ?params:Dynamic = null) : Void
  {
    Flurry.logEvent(name, params);
  }
}
