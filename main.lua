function love.load()
  Lynput = require("Lynput")
  Lynput.load_key_callbacks()
  Lynput.load_mouse_callbacks()
  Lynput.load_gamepad_callbacks()
  lynput = Lynput()
  
  lynput:bind("exit", "release escape")

  lynput:attachGamepad("GPAD_1")

  lynput:bind("pressing", {"press p", "press LMB", "press G_A"})
  lynput:bind("releasing", {"release r", "release RMB", "release G_B"})
  lynput:bind("holding", {"hold h", "hold MMB", "hold G_X"})

  lynput:unbindAll("holding")
  
  lynput:bind("moveLeft", {"-100:-50 G_LEFTSTICK_X"})
  lynput:bind("moveRight", {"50:100 G_LEFTSTICK_X"})

  lynput:unbind("moveRight", "50:100 G_LEFTSTICK_X")
  
  lynput:bind("RTing", "0:100 G_RT")

  lynput:bind("pressAny", "press any")
  lynput:bind("releaseAny", "release any")
  lynput:bind("holdAny", "hold any")
end


function love.update(dt)
  if lynput.exit then
    love.event.quit()
  end -- if exit

  if lynput.pressAny then
    print("Pressed ANY")
  end --

  if lynput.releaseAny then
    print("Released ANY")
  end --

  if lynput.holdAny then
    print("Holding ANY")
  end
  
  if lynput.pressing then
    print("Pressing")
  end -- if pressing

  if lynput.releasing then
    print("Releasing")
    lynput:unbind("releasing", {"release r", "release RMB", "release G_B"})
  end -- if releasing

  if lynput.holding then
    print("Holding")
  end -- if holding

  if lynput.moveLeft then
    print("moving left")
  end -- if moveLeft

  if lynput.moveRight then
    print("Moving right")
  end -- if moveRight

  if lynput.RTing then
    print("RTing")
  end -- if RTing

  
  Lynput.update_(dt)
end


function love.draw()
  love.graphics.setColor(255, 255, 255)
end
