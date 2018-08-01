-- TODO: Implementation without libraries
Object = require("lib.classic.classic")

Lynput = Object:extend()

Lynput.s_lynputs = {}
Lynput.s_idCount = 0
Lynput.s_count = 0

-- TODO: More reserved words such as:
-- - reserved characters
-- - lynput variables stored in "self"
Lynput.s_reserved_words = {
  "and", "break", "do", "else", "elseif", "end", "false", "for", 
  "function", "if", "in", "local", "nil", "not", "or", "repeat", 
  "return", "then", "true", "until", "while"
}

----------------
-- DICTIONARIES
----------------
Lynput.s_mouseButtons = {
  ["1"]="lmb", ["2"]="rmb", ["3"]="mmb", ["x1"]="mb4", ["x2"]="mb5"
}

-----------------------
-- FUTURE DICTIONARIES
-----------------------
-- Lynput.s_mouse_axes = {
--   "wd", "wu"
-- }

-- Lynput.s_gamepad_axes = {
--   "leftx", "lefty", "rightx", "righty", "triggerleft", "triggerright"
-- }

-- -- FIXME: Input names have to be unique, conflict with keyboard
-- -- May add a preffix like gstart for start or ga for a, or gamepad_a for a
-- Lynput.s_gamepad_buttons = {
--   "a", "b", "x", "y", "back", "guide", "start", "leftstick", 
--   "rightstick", "leftshoulder", "rightshoulder", "dppup", "dpdown", 
--   "dpleft", "dpright"
-- }


function Lynput:new()
  self.inputsSet = {}

  self.id = tostring(Lynput.s_idCount)
  Lynput.s_lynputs[self.id] = self
  Lynput.s_idCount = Lynput.s_idCount + 1
  Lynput.s_count = Lynput.s_count + 1
end


local function _isActionValid(action)
  if type(action) ~= "string" then
    return false
  end -- if not string
  
  for i,v in ipairs(Lynput.s_reserved_words) do
    if v == action then
      return false
    end -- if s_reserved_word
  end -- for each s_reserved_words
  
  return true
end


local function _isInputValid(input)
  for k,v in pairs(Lynput.s_mouseButtons) do
    if v == input then
      return true
    end -- if v == input
  end -- for each LÖVE mouse button
  
  -- TODO: Gamepad buttons
  -- TODO: Gamepad axes
  -- TODO: Touch screen

  return love.keyboard.getScancodeFromKey(input)
end


function Lynput:remove()
  Lynput.s_lynputs[self.id] = nil
  Lynput.s_count = Lynput.s_count - 1
end


function Lynput:bind(action, inputs)
  -- Transforms 1 input to a table
  if type(inputs) == "string" then
    local input = inputs
    inputs = {}
    inputs[1] = input
  end -- if only one input was given

  -- Process input
  for _,input in ipairs(inputs) do
    -- Is action valid?
    assert(
      _isActionValid(action),
      "Could not bind input->" .. input ..
      -- TODO: Check documentation for valid actions message
	"  to action->" .. action .. ", the action is not valid"
    )
    -- Is input valid?
    assert(
      _isInputValid(input),
      "Could not bind input->" .. input ..
      -- TODO: Check documentation for valid inputs message
	"  to action->" .. action .. ", the input is not valid"
    )
    
    -- FIXME: Pressed and released do not work for movement inputs
    if not self[action] then
      self[action] = {}
      self[action].pressed = false
      self[action].released = false
      self[action].holding = false
    end -- if action not set
    
    self.inputsSet[input] = action
  end -- for each input
end


function Lynput:unbind(action, inputs)
  -- Transforms 1 input to a table
  if type(inputs) == "string" then
    local input = inputs
    inputs = {}
    inputs[1] = input
  end -- if only one input was given

  -- Process input
  for _,input in ipairs(inputs) do
    -- Is action set?
    assert(
      self[action],
      "Could not unbind input->" .. input .. 
	"  to action->" .. action .. ", the action is not set"
    )
    -- Is input set?
    assert(
      self.inputsSet[input],
      "Could not unbind input->" .. input .. 
	"  to action->" .. action .. ", the input is not set"
    )
    
    self.inputsSet[input] = nil
    self[action].pressed = false
    self[action].holding = false
    self[action].released = false
  end -- for each input
end


function Lynput:unbindAll(action)
  -- Is action set?
  assert(
    self[action],
    "Could not unbind all inputs in action->" .. action ..
      ", the action is not set"
  )

  for k, v in pairs(self.inputsSet) do
    if v == action then
      self.inputsSet[k] = nil
    end -- if v == action
  end -- for each input set
end


function Lynput:removeAction(action)
  -- Is action set?
  assert(
    self[action],
    "Could not remove action->" .. action ..
      ", the action is not being used"
  )
  
  self:unbindAll(action)
  self[action] = nil
end


function Lynput:update()
  -- It's not possible to iterate actions through "self" because it
  -- also contains the inputsSet table
  for _,v in pairs(self.inputsSet) do
    -- FIXME: Only works if lynput is updated after input processing
    self[v].pressed = false
    self[v].released = false
  end -- for each action set
end


---------------------------------
-- KEYBOARD CALLBACKS
---------------------------------
function Lynput.onkeypressed(key)
  for k,v in pairs(Lynput.s_lynputs) do
    if v.inputsSet[key] then
      action = v.inputsSet[key]
      v[action].pressed = true
      v[action].holding = true
      v[action].released = false
    end -- key is set
  end -- for each s_lynputs
end


function Lynput.onkeyreleased(key)
  for k,v in pairs(Lynput.s_lynputs) do
    if v.inputsSet[key] then
      action = v.inputsSet[key]
      v[action].released = true
      v[action].pressed = false
      v[action].holding = false
    end -- key is set
  end -- for each s_lynputs
end


--------------------------------------
-- MOUSE CALLBACKS
--------------------------------------
function Lynput.onmousepressed(button)
  -- Translate LÖVE button to Lynput button
  button = Lynput.s_mouseButtons[tostring(button)]
  -- Process button
  for k,v in pairs(Lynput.s_lynputs) do
    if v.inputsSet[button] then
      action = v.inputsSet[button]
      v[action].pressed = true
      v[action].holding = true
      v[action].released = false
    end -- button is set
  end -- for each s_lynputs
end


function Lynput.onmousereleased(button)
  -- Translate LÖVE button to Lynput button
  button = Lynput.s_mouseButtons[tostring(button)]
  -- Process Lynput button
  for k,v in pairs(Lynput.s_lynputs) do
    if v.inputsSet[button] then
      action = v.inputsSet[button]
      v[action].released = true
      v[action].pressed = false
      v[action].holding = false
    end -- button is set
  end -- for each s_lynputs
end
