function love.load()
  require("Lynput")
  lynput = Lynput()
  lynput:bind("exit", "escape")
  
  lynput:bind("pressing", {"p", "lmb"})
  lynput:bind("releasing", {"r", "rmb"})
  lynput:bind("holding", {"h", "mmb"})
  
  lynput:unbindAll("holding")
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
    lynput:unbind("releasing", {"r", "rmb"})
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
