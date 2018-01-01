package deengames.abook.owlicious.elements;

import deengames.abook.core.Element;
import deengames.abook.core.Screen;
import deengames.math.DiscreteRandom;

class Cloud extends Element
{
    public function new(json:Dynamic)
    {
        super(json);
        this.setClickAudio('assets/audio/bubble-pop');
        this.resetPosition();
        
        this.x = Math.random() * Main.gameWidth; // Initially, not all at RHS
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (this.x <= -this.width) {
            this.resetPosition();
        }
    }
    
    public function resetPosition():Void
    {
        // Pick cloud image
        var num = Math.floor(Math.random() * 2) + 1;
        this.setImage('assets/images/cloud-${num}');
        
        // respawn on RHS of screen
        this.x = Main.gameWidth;
        // Randomize y
        this.y = Math.random() * (Main.gameHeight - this.height);
        this.velocity.x = -1 * ((Math.random() * 200) + 300); // 200-500
        // Reset if popped
        this.alpha = 1;
        
        // Owl's z is 5, so half clouds are over and half are under
        // 0...10
        this.z = Math.round((Math.random() * 10));        
        Screen.currentScreen.sortElementsByZ();
        
        var pitch:Float = DiscreteRandom.pick([0.8, 1.0, 1.2]);
        this.setAudioPitch(pitch);
    }
    
    override public function clickHandler(object:flixel.FlxObject):Void
    {
        super.clickHandler(object);
        this.alpha = 0;
    }
}