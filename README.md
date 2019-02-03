# Lynput

[![LÖVE VERSION](https://img.shields.io/badge/L%C3%96VE-0.10.0%2B-%23E0539A.svg)](https://love2d.org/wiki/Category:Versions)
[![MIT LICENSE](https://img.shields.io/badge/license-MIT-%233DCE7A.svg)](LICENSE)

![lynput logo](res/logo.png)

## Index
- [What is Lynput?](#what-is-lynput)
- [Installation](#installation)
- [Usage](#usage)
- [Devices supported](#devices-supported)
- [Features](#features)
- [What does Lynput mean?](#what-does-lynput-mean)
- [I've found a bug, what do I do?](#ive-found-a-bug-what-do-i-do)
- [Contact](#contact)
- [License](#license)

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

## Installation
Just download the [<code>Lynput.lua</code>](Lynput.lua) file. Place it anywhere you want inside your game folder, just be careful with the path when requiring the library. Also remember that this file name starts with a capital letter.

## Usage
See <code>[MANUAL](MANUAL.md)</code> for more information.

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

## What does Lynput mean?
```lua
if not creativity then
    name = Lydzje + input
    print(name)
end -- if not creativity
```
> **Output:**
>
> Lynput

## I've found a bug, what do I do?
If you want to report a bug (please do!), [open a new issue](https://github.com/Lydzje/lynput/issues). As another option just [contact me](#contact).

## Contact
If you need to contact me don't hesitate to [send me an email](mailto:to.lydzje@gmail.com). If you preffer other way, please visit the contact section in my website [lydzje.com](https://lydzje.com).

## License
This software is licensed under the MIT license. Check the details by clicking [here](LICENSE)
