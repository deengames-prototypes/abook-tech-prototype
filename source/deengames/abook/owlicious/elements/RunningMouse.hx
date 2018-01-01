package deengames.abook.owlicious.elements;

import deengames.abook.core.Element;
import deengames.abook.core.Screen;
import deengames.io.AudioManager;
import deengames.math.DiscreteRandom;

import flixel.FlxObject;

// mouse or rat
class RunningMouse extends Element
{
    private static inline var RUN_SPEED:Int = 200;
    
    public function new(x:Float, y:Float, runDirection:String)
    {
        var species = (Math.round(Math.random() * 100) % 2) == 0 ? "mouse" : "rat";
        super();
        this.setImage('assets/images/${species}-running');
        this.setClickAudio("assets/audio/mouse-squeak");        
        this.x = x;
        this.y = y + 32;
        this.velocity.x = (runDirection == "left" ? -1 : 1) * RUN_SPEED;
        // +- 20% velocity
        var modifier = 1 + (Math.random() * 0.4) - 0.2;
        this.velocity.x *= modifier;
        this.velocity.y = Math.random() * 50;
        if (runDirection == "left")
        {
            this.flipX = true;
        }
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (this.x < -this.width || this.x > Main.gameWidth || this.y >= Main.gameHeight)
        {
            // Notify the owl that we got away
            for (e in Screen.currentScreen.elements)
            {
                if (Std.is(e, HuntingOwl))
                {
                    var owl:HuntingOwl = cast(e, HuntingOwl);
                    owl.gotAway(this);
                    break;
                }
            }
            
            Screen.currentScreen.remove(this);
            Screen.currentScreen.elements.remove(this);
            this.destroy();
        }
    }
}