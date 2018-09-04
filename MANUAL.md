# Lynput Manual (In progress) :construction::construction:

## Index
- [Quick examples](#quick-examples)
  - [Player movement](#player-movement)
- [Usage](#usage)
  - [Lynput callbacks](#lynput-callbacks)
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

## License
