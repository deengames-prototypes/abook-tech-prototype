package deengames.abook.controls;

import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.input.mouse.FlxMouseEventManager;

import deengames.abook.core.Screen;

// Next/previous
class ChangeScreenButton extends FlxSprite
{
    public function new(target:Dynamic, showNext:Bool)
    {
        super();
        var state:String = showNext ? "next" : "previous";
        this.loadGraphic('assets/images/${state}-button.png');
        if (showNext)
        {
            this.x = FlxG.width - this.width - 32;
        } else {
            this.x = 32;
        }
        this.y = (FlxG.height - this.height) / 3;
        
        FlxMouseEventManager.add(this, null, function(sprite:FlxSprite)
        {
            Screen.transitionTo(Screen.createInstance(target));
        });
    }
}
