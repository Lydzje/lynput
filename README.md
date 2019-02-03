# Lynput

[![LÖVE VERSION](https://img.shields.io/badge/L%C3%96VE-0.10.0%2B-%23E0539A.svg)](https://love2d.org/wiki/Category:Versions)
[![MIT LICENSE](https://img.shields.io/badge/license-MIT-%233DCE7A.svg)](LICENSE)

## What is Lynput?
**Lynput** is an input library for [LÖVE](https://love2d.org/) that  makes input handling very easy and intuitive 💙. It will make you able to do things like this:

```lua
function love.load()
  Lynput = require("Lynput") -- Load Lynput
  Lynput.load_key_callbacks() -- Load keyboard callbacks
  control = Lynput() -- Create a Lynput object
  
  control:bind(
    "moveLeft",
    {
      "hold left",
      "hold a",
    }
  )
  control:bind(
    "moveRight",
    {
      "hold right",
      "hold d",
    }
  )
  control:bind("action", "press f")
  control:bind("obey", "release any")
end

function love.update(dt)
  if control.moveLeft  then x = x - speed * dt end
  if control.moveRight then x = x + speed * dt end
  if control.action    then triggerAction()    end
  if control.obey      then obey()             end
  
  Lynput.update_(dt) -- Update Lynput
end
```

SEE THE [MANUAL](MANUAL.md) FOR MORE DETAILS.

## Installation
Just download the <code>Lynput.lua</code> file. Place it anywhere you want inside your game folder, just be careful with the path when requiring the library. Also remember that this file name starts with a capital letter.

## Devices supported
- [x] Keyboard
- [x] Mouse buttons
- [x] Gamepad buttons
- [x] Gamepad analog input
- [ ] Touch screen
- [ ] ...

## Features
- [x] Multiple independent input objects
- [x] Easy and intuitive input binding and unbindig
- [ ] Saving and loading input configuration files
- [ ] Things like this: <code>lynput:bind("superPunch", "press G_RB+G_X")</code>
- [ ] ...

## Lynput?
```lua
if not creativity then
    name = Lydzje + input
    print(name)
end -- if not creativity
```
> **Output:**
>
> Lynput

## License
This software is licensed under the MIT license. Check the details by clicking [here](LICENSE).
