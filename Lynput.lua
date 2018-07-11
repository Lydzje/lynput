-- TODO: Implementation without libraries
Object = require("lib.classic")

Lynput = Object:extend()

Lynput.s_lynputs = {}
Lynput.s_idCount = 0
Lynput.s_count = 0

Lynput.s_reserved_words = {
  "and", "break", "do", "else", "elseif", "end", "false", "for", 
  "function", "if", "in", "local", "nil", "not", "or", "repeat", 
  "return", "then", "true", "until", "while"
}

Lynput.s_mouse_buttons = {
  lmb="1", rmb="2", mmb="3", mb4="x1", mb5="x2"
}

Lynput.s_mouse_axes = {
  "wd", "wu"
}

Lynput.s_gamepad_axes = {
  "leftx", "lefty", "rightx", "righty", "triggerleft", "triggerright"
}

-- FIXME: Input names have to be unique, conflict with keyboard
-- May add a preffix like gstart for start or ga for a, or gamepad_a for a
Lynput.s_gamepad_buttons = {
  "a", "b", "x", "y", "back", "guide", "start", "leftstick", 
  "rightstick", "leftshoulder", "rightshoulder", "dppup", "dpdown", 
  "dpleft", "dpright"
}


function Lynput:new()
  self.inputsSet = {}

  self.id = tostring(Lynput.s_idCount)
  Lynput.s_lynputs[self.id] = self
  Lynput.s_idCount = Lynput.s_idCount + 1
  Lynput.s_count = Lynput.s_count + 1
end


local function isActionValid(action)
  if type(action) ~= "string" then
    -- TODO: "Could not bind INPUT TO ACTION"
    error(
      "Could not bind action->" .. action .. 
      " to input, the action is not a string"
    )
    return false
  end -- if not string

  -- TODO: Not valid if contains spaces or reserved characters

  for i,v in ipairs(Lynput.s_reserved_words) do
    if v == action then
    -- TODO: "Could not bind INPUT TO ACTION"
      error(
        "Could not bind action->" .. action .. 
        " to input, the action name is a reserved word"
      )
      return false
    end -- if s_reserved_word
  end -- for each s_reserved_words

  return true
end


local function isInputValid(input)
  if Lynput.s_mouse_buttons[input] then
    return true, "mButton"
  elseif love.keyboard.getScancodeFromKey(input) then
    return true, "keyboard"
  end -- if input exists

  -- TODO: Gamepad axes
  -- TODO: Gamepad buttons
  -- TODO: Touch screen
  return false
end


function Lynput:bind(action, input)
  -- TODO: input has to be an array of inputs
  local actionValid = isActionValid(action)
  local inputValid, type = isInputValid(input)
  if actionValid and inputValid then
    local input = input
    if type == "mButton" then
      input = Lynput.s_mouse_buttons[input]
    end -- if mButton
    
    -- FIXME: Pressed and released do not work for movement inputs
      if not self[action] then
        -- action not set yet
        self[action] = {}
        self[action].pressed = false
        self[action].released = false
        self[action].holding = false
        self[action].inputs = {}

      if self.inputsSet[input] then
        -- input in use
        actionSet = self.inputsSet[input]
        i = 1
        found = false
        len = #(self[actionSet].inputs)
        while i <= len and not found do
          if self[actionSet].inputs[i] == input then
            found = true
            -- removed input in the action it was assigned to
            self[actionSet].inputs[i] = nil
          end -- if input found
        end -- while input not found
      end -- if input already in use
    end -- if action not set
    
    self.inputsSet[input] = action
    len = #(self[action].inputs)
    self[action].inputs[len+1] = input
  end -- if action and input are valid
end


function Lynput:unbind(action, input)
  -- TODO: input has to be an array of inputs
  if self[action] then
    if self.inputsSet[input] then
      self.inputsSet[input] = nil
      for i,v in ipairs(self[action].inputs) do
        if v == input then
          self[action].inputs[i] = nil
          break
        end -- if input found
      end -- for each input assigned to action
    else
      error(
      "Could not unbind input->" .. input .. 
      " to action->" .. action .. ", the input is not set"
      )
    end -- if input is set
  else
    error(
      "Could not unbind input->" .. input .. 
      " to action->" .. action .. ", the action is not set"
    )
  end -- if action is set
end


function Lynput:remove()
  Lynput.s_lynputs[self.id] = nil
  Lynput.s_count = Lynput.s_count - 1
end


function Lynput:update()
  for k,v in pairs(self.inputsSet) do
    -- FIXME: Only works if lynput is updated after input processing
    self[v].pressed = false
    self[v].released = false
  end
end


-----------------------------
-- KEYBOARD CALLBACKS
-----------------------------
function Lynput.key_pressed(key)
  for k,v in pairs(Lynput.s_lynputs) do
    if v.inputsSet[key] then
      action = v.inputsSet[key]
      v[action].pressed = true
      v[action].holding = true
      v[action].released = false
    end -- key is set
  end -- for each s_lynputs
end


function Lynput.key_released(key)
  for k,v in pairs(Lynput.s_lynputs) do
    if v.inputsSet[key] then
      action = v.inputsSet[key]
      v[action].released = true
      v[action].pressed = false
      v[action].holding = false
    end -- key is set
  end -- for each s_lynputs
end


-----------------------------
-- MOUSE CALLBACKS
-----------------------------
function Lynput.mouse_pressed(button)
  button = tostring(button)
  for k,v in pairs(Lynput.s_lynputs) do
    if v.inputsSet[button] then
      action = v.inputsSet[button]
      v[action].pressed = true
      v[action].holding = true
      v[action].released = false
    end -- button is set
  end -- for each s_lynputs
end


function Lynput.mouse_released(button)
  button = tostring(button)
  for k,v in pairs(Lynput.s_lynputs) do
    if v.inputsSet[button] then
      action = v.inputsSet[button]
      v[action].released = true
      v[action].pressed = false
      v[action].holding = false
    end -- button is set
  end -- for each s_lynputs
end
