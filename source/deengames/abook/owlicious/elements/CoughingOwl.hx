package deengames.abook.owlicious.elements;

import flixel.FlxObject;

import deengames.io.AudioManager;
import deengames.abook.core.Element;
import deengames.abook.core.Screen;
import deengames.abook.owlicious.elements.OwlPellet;

class CoughingOwl extends Element
{
    public function new(json:Dynamic)
    {
        super();
    }
    
    override public function clickHandler(obj:FlxObject):Void
    {
        super.clickHandler(obj);
        // Play audio on a separate thread
        var screen:Screen = Screen.currentScreen;
        // Come out of your mouth (width / 2, height)
        var pellet = new OwlPellet();
        screen.add(pellet);
        screen.elements.push(pellet);
    }    
}