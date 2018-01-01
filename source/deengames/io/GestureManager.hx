package deengames.io;

import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.plugin.FlxMouseControl;
import flixel.input.mouse.FlxMouseEventManager;

class GestureManager extends FlxObject
{
  private var gestureStart:FlxPoint;

  // TODO: support more than one callback per gesture
  // TODO: take a sprite or pressed-on object instead of the direction only
  private var callbacks:Map<Gesture, SwipeDirection->Void> = new Map<Gesture, SwipeDirection->Void>();

  public function new() {
      super();
      this.setSize(Main.gameWidth, Main.gameHeight);
      FlxG.plugins.add(new FlxMouseControl());
      FlxMouseEventManager.add(this, onMouseDown, onMouseUp);
  }

  public function onGesture(gesture:Gesture, callback:SwipeDirection->Void)
  {
    callbacks.set(gesture, callback);
  }

  public function onMouseDown(object:FlxObject):Void
  {
    if (this.gestureStart == null) {
      // TODO: use world position
      this.gestureStart = FlxG.mouse.getScreenPosition();
    }
  }
  
  public function onMouseUp(obejct:FlxObject):Void
  {
      if (gestureStart != null)
      {
        var gesture:Gesture = Gesture.Swipe; // TODO: detect, implement more
        var gestureStop:FlxPoint = FlxG.mouse.getScreenPosition();
        var vector:FlxPoint = new FlxPoint(gestureStop.x - gestureStart.x, gestureStop.y - gestureStart.y);

        var swipeMagnitude:Float = (vector.x * vector.x) + (vector.y * vector.y);
        // Make sure it's not too small to tell what the user wants (a few pixels of movement)
        // Note that this value is in virtual pixels, i.e. if the game is scaled down to the
        // device, a tiny physical movement with register as a large magnitude
        if (swipeMagnitude >= 500) {
            var swipeDirection:SwipeDirection;
            if (Math.abs(vector.x) >= Math.abs(vector.y)) {
                swipeDirection = vector.x > 0 ? SwipeDirection.Right : SwipeDirection.Left;
            } else {
            swipeDirection = vector.y > 0 ? SwipeDirection.Down : SwipeDirection.Up;
            }

            if (this.callbacks.exists(Gesture.Swipe)) {
            var callback:SwipeDirection->Void = this.callbacks.get(Gesture.Swipe);
            callback(swipeDirection);
            }
        }

      this.gestureStart = null;
    }
  }
}

enum Gesture {
  Swipe;
}

enum SwipeDirection {
  Left;
  Right;
  Up;
  Down;
}
