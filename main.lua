function love.load()
  require("Lynput")
  lynput = Lynput()
  lynput:bind("exit", "release escape")

  lynput:attachGamepad("GPAD_1")
  lynput:bind("pressing", {"press p", "press LMB", "press G_A"})
  lynput:bind("releasing", {"release r", "release RMB", "release G_B"})
  lynput:bind("holding", {"hold h", "hold MMB", "hold G_X"})

  lynput:unbind("pressing", "press LMB")
  lynput:unbindAll("holding")
end


function love.update(dt)
  if lynput.exit then
    love.event.quit()
  end -- if exit

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

  lynput:update(dt)
end


function love.draw()
  love.graphics.setColor(255, 255, 255)
end


-----------------------------
-- CALLBACKS
-----------------------------
function love.keypressed(key)
  Lynput.onkeypressed(key)
end


function love.keyreleased(key)
  Lynput.onkeyreleased(key)
end


function love.mousepressed(x, y, button, istouch)
  Lynput.onmousepressed(button)
end


function love.mousereleased(x, y, button, istouch)
  Lynput.onmousereleased(button)
end


function love.gamepadpressed(joystick, button)
  Lynput.ongamepadpressed(joystick:getID(), button)
end


function love.gamepadreleased(joystick, button)
  Lynput.ongamepadreleased(joystick:getID(), button)
end


function love.joystickadded(joystick)
  Lynput.ongamepadadded(joystick:getID())
end
