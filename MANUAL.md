# Lynput Manual (In progress) :construction::construction:

## Index
- [Quick examples](#quick-examples)
  - [Player movement](#player-movement)
- [Usage](#usage)
  - [Lynput callbacks](#lynput-callbacks)
  - [Format for an action name](#format-for-an-action-name)
- [License](#license)

## Quick examples
### Player movement
```lua
-- Load Lynput
require("path.to.Lynput")
```

```lua
-- Set callbacks
function love.keypressed(key)
  Lynput.onkeypressed(key)
end

function love.keyreleased(key)
  Lynput.onkeyreleased(key)
end
```

```lua
-- Update Lynput
function love.update(dt)
  Lynput.update_(dt)
end
```

```lua
-- Create Lynput object
player.controls = Lynput()
-- Bind commands to actions, for Lynput "moveLeft" is an action and "hold a" is a command
player.controls:bind("moveLeft", "hold a")
player.controls:bind("moveRight", "hold d")
```

```lua
-- Check player actions
if player.controls.moveLeft then
  player.x = player.x - player.speed
end -- if player moves left

if player.controls.moveRight then
  player.x = player.x + player.speed
end -- if player moves right
```

## Usage
### Lynput callbacks
To make Lynput able to check your computer input, it's necessary to set its callbacks. Only set those that will be used.

#### Keyboard callbacks
```lua
function love.keypressed(key)
  Lynput.onkeypressed(key)
end

function love.keyreleased(key)
  Lynput.onkeyreleased(key)
end
```

#### Mouse callbacks
```lua
function love.mousepressed(x, y, button, istouch)
  Lynput.onmousepressed(button)
end

function love.mousereleased(x, y, button, istouch)
  Lynput.onmousereleased(button)
end
```

#### Gamepad callbacks
```lua
function love.gamepadpressed(joystick, button)
  Lynput.ongamepadpressed(joystick:getID(), button)
end

function love.gamepadreleased(joystick, button)
  Lynput.ongamepadreleased(joystick:getID(), button)
end

function love.joystickadded(joystick)
  Lynput.ongamepadadded(joystick)
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
