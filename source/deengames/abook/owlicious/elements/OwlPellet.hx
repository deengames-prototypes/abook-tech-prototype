package deengames.abook.owlicious.elements;

import flixel.math.FlxPoint;
import deengames.io.AudioManager;
import deengames.abook.core.Element;
import deengames.abook.core.Screen;

class OwlPellet extends Element
{
    private var stopX:Float;
    private var stopY:Float;
    
    public function new()
    {
        super();
        
        this.setImage('assets/images/owl-pellet');
        this.setClickAudio('assets/audio/speech-owl-pellet-info');
        
        this.x = 750 - (this.width / 2);
        this.y = 410 - (this.height / 2);

        this.stopX = this.x - 350;
        this.stopY = this.y + 100;
        
        // Double the distance to travel => 0.5s travel time
        this.velocity = new FlxPoint(2*(this.stopX - this.x), 2*(this.stopY - this.y));
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (this.x <= this.stopX && this.y >= this.stopY && this.velocity.y > 0)
        {
            // Snap to the correct position so they all line up
            this.x = this.stopX;
            this.y = this.stopY;
            this.velocity = new FlxPoint(0, 0);
        }
    }
}