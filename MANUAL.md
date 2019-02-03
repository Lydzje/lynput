# Lynput Manual (In progress) :construction::construction:

## Index
- [Usage](#usage)
  - [Basics](#basics)
  - [Lynput callbacks](#lynput-callbacks)
  - [Input states](#input-states)
    - [Buttons](#buttons)
    - [Axes](#axes)
  - [Keyboard](#keyboard)
  - [Mouse](#mouse)
  - [Gamepad](#gamepad)
  - [Format for an action name](#format-for-an-action-name)
- [License](#license)

## Usage
### Basics
First you need to load the library:
```lua
Lynput = require("path.to.Lynput") -- Notice that the file starts with a capital letter
```
Then, you need to create a Lynput object:
```lua
control = Lynput()
```
Lynput objects need to be updated in order to work:
```lua
-- put this after all your game logic happens, for example at the bottom of love.update(dt)
Lynput.update_(dt) -- Notice the underscore
```
Once you don't need the object anymore, destroy it with:
```lua
control:remove()
```

### Lynput callbacks
To make Lynput able to check your computer input, it's necessary to set its callbacks. You can set them by yourself, or you can let Lynput do this job. Do it yourself if you need to override the LÖVE callbacks with more stuff aside from Lynput callbacks. 

Only set those that will be used for better performance.

#### Keyboard callbacks
To make Lynput load the keyboard callbacks:
```lua
Lynput.load_key_callbacks()
```
To load them by yourself, override this love functions as indicated:
```lua
-- Write the code below to load them by yourself
function love.keypressed(key)
  -- your stuff
  Lynput.onkeypressed(key)
  -- your stuff
end

function love.keyreleased(key)
  -- your stuff
  Lynput.onkeyreleased(key)
  -- your stuff
end
```

#### Mouse callbacks
To make Lynput load the mouse callbacks:
```lua
Lynput.load_mouse_callbacks()
```
To load them by yourself, override this love functions as indicated:
```lua
function love.mousepressed(x, y, button, istouch)
  -- your stuff
  Lynput.onmousepressed(button)
  -- your stuff
end

function love.mousereleased(x, y, button, istouch)
  -- your stuff
  Lynput.onmousereleased(button)
  -- your stuff
end
```

#### Gamepad callbacks
To make Lynput load the gamepad callbacks:
```lua
Lynput.load_gamepad_callbacks()
```
To load them by yourself, override this love functions as indicated:
```lua
function love.gamepadpressed(joystick, button)
  -- your stuff
  Lynput.ongamepadpressed(joystick:getID(), button)
  -- your stuff
end

function love.gamepadreleased(joystick, button)
  -- your stuff
  Lynput.ongamepadreleased(joystick:getID(), button)
  -- your stuff
end

function love.joystickadded(joystick)
  -- your stuff
  Lynput.ongamepadadded(joystick)
  -- your stuff
end
```

### Format for an action name
It's not possible to use any name for an action because there are some reserved words and characters that can't be used. Those names are:

TODO: BETTER FORMAT

and, break, do, else, elseif, end, false, for, function, if, in, local, nil, not, or, repeat, return, then, true, until, while, inputsSet, gpad, gpadDeadZone, id, remove, attachGamepad, bind, unbind, unbindAll, removeAction, update

or anyone that contains the characters below:

FIXME: Remove operators, leave only characters

+, -, *, /, %, ^, #, ==, ~=, <=, >=, <, >, =, (, ), {, }, [, ], ;, :, ,, ., .., ... 

## License
Soon.
