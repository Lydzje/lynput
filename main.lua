function love.load()
  require("Lynput")
  lynput = Lynput()
  lynput:bind("exit", "escape")
  
  -- keyboard
  lynput:bind("pressing", "p")
  lynput:bind("releasing", "r")
  lynput:bind("holding", "h")

  -- mouse buttons
  lynput:bind("pressing", "lmb")
  lynput:bind("releasing", "rmb")
  lynput:bind("holding", "mmb")
end


function love.update(dt)
  if lynput.exit.released then
    love.event.quit()
  end -- if exit
  if lynput.pressing.pressed then
    print("Pressing")
  end -- if pressing
  if lynput.releasing.released then
    print("Releasing")
  end -- if releasing
  if lynput.holding.holding then
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
  Lynput.key_pressed(key)
end


function love.keyreleased(key)
  Lynput.key_released(key)
end


function love.mousepressed(x, y, button, istouch)
  Lynput.mouse_pressed(button)
end


function love.mousereleased(x, y, button, istouch)
  Lynput.mouse_released(button)
end
