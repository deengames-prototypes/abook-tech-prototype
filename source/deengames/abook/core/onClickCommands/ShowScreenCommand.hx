package deengames.abook.core.onClickCommands;

import deengames.abook.core.Screen;

class ShowScreenCommand {
  private var screenData:Dynamic;

  public function new(screenData:Dynamic) {
    this.screenData = screenData;
  }

  public function execute() {
    var screen = Screen.createInstance(this.screenData);
    Screen.transitionTo(screen);
  }
}
