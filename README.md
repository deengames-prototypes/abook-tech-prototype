The framework and a technical demo of an abook. If you're working on the next abook game, copy this repository as a base and trim game-specific screen classes (there shouldn't be many of those).

# Configuring Game.json

## Basic Configuration

A `Game.json` file in `assets` drives the content currently. **Any changes are automatically reloaded (including changed assets) when you use `-debug`.** For more information, see the `Debugging` section.

Here's how you can use `Game.json` to create scenes with interactive elements, without writing a lick of code.

The basic structure includes `width` and `height` elements (the "virtual" or "game" size, which is scaled up/down to fit onto the current device screen). and an array of `screens`.

## Screens
Each `screen` should at least have a `name`,  `backgroundImage`, and `audio`:

```
"screens": [
  { "name": "title screen", "backgroundImage": "titleScreen3.jpg", "audio": "title" },
  { "name": "intro screen", "backgroundImage": "bg/intro", "audio": "speech/sunny-day" }
]
```

The first screen shows when the player loads the game (after the splash screen).

Images are all relative to `assets/images`. If the image doesn't include an extension, `.png` is used. Audio files are relative to `assets/audio`, and the extension depends on the platform (`mp3` for Flash, `ogg` for all others).

All screens already include the audio button, which the user can click to replay the `audio` file.

You can also specify a `backgroundAudio` property, which loops the specified audio as long as the screen displays.

Scenes with just a background and audio would be boring (TIML, anyone?), so you should also include an array of interactive `elements` in each scene.

## Interactive Elements

Elements can include an image (or spritesheet/animation), and an audio to play on click:

```
"elements": [
  { "image": "sprites/mokey", "x": "32", "y": "32", "clickAudio": "sfx/monkey-noises" },
  {  "x": "64", "y": "96", "animation": { "image": "monkey_helmet", "width": 50, "height": 55, "frames": 8, "fps": 8 } }
]
```

In this example, the first element is a monkey sprite positioned at `(32, 32)` which plays `assets/audio/sfx/monkey-noises` when clicked. The second example is a spritesheet of `monkey_helmet` at `(64, 96)`. The animation frames are `50x55` pixels each. The first frame shows until the player clicks on it, at which point all eight frames play at 8fps. You can also specify a `z` value (higher values are drawn on top of lower values).

Elements appear relative to the top-left corner of the screen by default. To position them relative to a different corner, specify `placement` with one of `["top-left", "top-center", "top-right", "bottom-left", "bottom-right"]` instead.

Elements can also specify an `onClick` handler, with the format `show(screen name)`. When clicked, the element transitions the player to the specified screen. (If the element has an animation, the animation doesn't play.)

You can also specify an `effect` on an element. Effects include:
- `silhouette`: blacks out the image. You can specify a darkness percentage, eg. `silhouette(75)` makes the image 75% dark

### Advanced Elements

Elements can have a `className` that specifies the name of that element's class. An instance of that class will be created at runtime. Restrictions include:
- The class name must be the full package and class name (eg. `deengames.abooks.owlicious.Cloud`)
- The class must have a constructor which takes a single JSON parameter (the element's JSON).
- The class must derive from `FlxBasic` so that you can call `FlxState.add(instance)`.

If the class derives from `Element`, then `create` is called after the class is fully setup (from the JSON).

You can use the constructor to read/process any JSON parameters and initialize your instance appropriately. 

## Advanced Screen Properties

You can also tag screens with some advanced properties:

- Specify `"show": false` to prevent the player from swiping to a screen. Screens like this can only be shown if the player adds an `onClick` event on an element to take the player to it. You should keep all special screens at the beginning or end of your `screens` array if possible (hidden screens are skipped when swiping). Good use-cases for these include a title or credits screen.
- Specify `"hideAudioButton": true` to hide the default audio button, preventing the user from playing back the screen's audio. This is useful in some cases, like a game over screen.
If you specify both `hideAudioButton` and `audio`, the audio will play once, but can't be repeated.
- Specify `"className": "deengames.foo.bar.AwesomeScreen"` to load and use a custom class for a screen. This class should meet the following criteria:
  - Extends from `deengames.abook.core.Screen`
  - Contains a `create` function which calls `super.create()`.
  - Exists in a package which is included in `Project.xml` via a `haxeflag`: `<haxeflag name="--macro" value="include('deengames.foo.bar')" />`. Without this, the custom screen class won't be included in the binary.
- Optional custom screen functionality:
  - You can include all other data as normal (eg. add elements, specify a background image/audio, etc.). If `super.create` is the first call in the `create` method, the other data is loaded first.
  - Make sure you call `super.update(elasped)` if you override `update`.

## Debugging
- Run `lime test <platform> -debug` to enable debugging.
- When running in `neko` with the `-debug` flag, **any changes to anything in `assets` automatically reload the game content.**
  - If the current screen still exists, the game reloads to that same screen.
- Even without `debug` enabled, running the app in `neko` generates a `debug.log` file with debug messages
- Make calls to `deengames.io.DebugLogger.log(...)` to log debug messages in debug mode (and to `debug.log`).

## Sample

Below is a sample `Game.json` config file that exercises all available functionality.

```
{
  "width": 1024,
  "height": 576,
  "screens": [
    {
      "name": "title screen",
      "backgroundImage": "titlescreen",
      "show": false,
      "hideAudioButton": true,
      "elements": [
        { "image": "house", "x": 32, "y": 32,
          "placement": "top-left", "onClick": "show(credits screen)"
        },
        {
          "animation": { "image": "monkey_helmet", "width": 50, "height": 55, "frames": 8, "fps": 8 },
          "clickAudio": "intro-1"
        }
      ]
    },
    {
      "name": "scene 14",
      "backgroundImage": "scene-15.jpg",
      "audio": "intro-1",
      "backgroundAudio": "brook"
    },
    {
      "name": "scene 27",
      "backgroundImage": "scene-27.jpg",
      "audio": "intro-2"
    },
    {
      "name": "the end screen",
      "className": "deengames.abook.khadijaskitten.TheEndScreen",
      "audio": "intro-3",
      "hideAudioButton": true
    },
    {
      "name": "credits screen",
      "show": false,
      "hideAudioButton": true,
      "backgroundImage": "credits-bg.jpg",
      "elements": [
        { "image": "restart", "x": 32, "y": 32, "placement": "bottom-right", "onClick": "show(title screen)" }
      ]
    }
  ]
}
```
