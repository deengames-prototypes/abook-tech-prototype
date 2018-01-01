package deengames.abook.owlicious.elements;

import flixel.FlxObject;

import deengames.abook.core.Element;
import deengames.abook.core.Screen;
import deengames.io.AudioManager;

class HuntingOwl extends Element
{
    private static inline var MOVE_SPEED:Int = 250;
    
    private var currentPrey:RunningMouse;
    private var roostX:Float;
    private var roostY:Float;
    private var size:Int;
    
    public function new(json:Dynamic)
    {
        super();        
    }
    
    override public function create()
    {
        super.create();
        
        this.roostX = this.x;
        this.roostY = this.y;
        // Half our approximate size
        // If the mouse is this far away, we got him.
        this.size = Math.round((this.width + this.height) / 4);
    }
    
    public function gotAway(m:RunningMouse)
    {
        if (this.currentPrey == m)
        {
            this.currentPrey = null;
        }
    }
    
    override public function update(elapsed:Float):Void
    {        
        super.update(elapsed);
        if (currentPrey == null)
        {
            // Find a mouse to prey on
            for (e in Screen.currentScreen.elements)
            {
                if (Std.is(e, RunningMouse))
                {
                    var mouse:RunningMouse = cast(e, RunningMouse);
                    currentPrey = mouse;
                    break;
                }
            }
        }
        
        // Looped through (now or previously) and found one
        if (currentPrey != null)
        {
            if (Math.abs(this.x - currentPrey.x) + Math.abs(this.y - currentPrey.y) <= this.size)
            {
                // Gotcha!
                // Play squeak noise
                currentPrey.clickHandler(this);
                currentPrey.destroy();
                Screen.currentScreen.remove(currentPrey);
                Screen.currentScreen.elements.remove(currentPrey);
                currentPrey = null;
            }
            else
            {
                // Swoop down on that dude
                this.target(currentPrey.x, currentPrey.y);
            }
        } 
        else
        {
            // Back to the roosting grounds
            this.target(roostX, roostY);
        }
    }
    
    private function target(targetX:Float, targetY:Float):Void
    {
        // If we're too close, don't jitter, just chill.
        if (Math.abs(this.x - targetX) + Math.abs(this.y - targetY) <= 50)
        {
            this.velocity.x = 0;
            this.velocity.y = 0;
        }
        else
        {
            // Move toward it naively. This is not a constant velocity
            // (we move faster on diagonals).
            var vx:Int = this.x < targetX ? MOVE_SPEED : -MOVE_SPEED;
            var vy:Int = this.y < targetY ? MOVE_SPEED : -MOVE_SPEED;
            this.velocity.x = vx;
            this.velocity.y = vy;
        }
    }
}