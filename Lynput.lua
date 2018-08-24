-- TODO: Implementation without libraries
Object = require("lib.classic.classic")

Lynput = Object:extend()

Lynput.s_lynputs = {}
Lynput.s_idCount = 0
Lynput.s_count = 0

Lynput.s_reservedNames = {
  -- Reserved by Lua
  "and", "break", "do", "else", "elseif", "end", "false", "for", 
  "function", "if", "in", "local", "nil", "not", "or", "repeat", 
  "return", "then", "true", "until", "while",
  -- TODO: Remove the comment below when a standalone version comes up
  -- Reserved by Classic is not supported since Lynput won't require any library in future
  -- Reserved by Lynput
  "inputsSet", "gpad", "gpadDeadZone", "id", "remove", "attachGamepad",
  "bind", "unbind", "unbindAll", "removeAction", "update"
}

Lynput.s_reservedCharacters = {
  "+", "-", "*", "/", "%", "^", "#", "==", "~=", "<=", ">=", "<", ">",
  "=", "(", ")", "{", "}", "[", "]", ";", ":", ",", ".", "..", "..."  
}

----------------
-- DICTIONARIES
----------------
Lynput.s_mouseButtons = {
  ["1"]="LMB", ["2"]="RMB", ["3"]="MMB", ["x1"]="MB4", ["x2"]="MB5"
}

Lynput.s_gamepadButtons = {
  ["a"]="G_A", ["b"]="G_B", ["x"]="G_X", ["y"]="G_Y",
  ["back"]="G_BACK", ["guide"]="G_GUIDE", ["start"]="G_START",
  ["leftstick"]="G_LEFTSTICK", ["rightstick"]="G_RIGHTSTICK",
  ["leftshoulder"]="G_LB", ["rightshoulder"]="G_RB",
  ["dpup"]="G_DPAD_UP", ["dpdown"]="G_DPAD_DOWN", 
  ["dpleft"]="G_DPAD_LEFT", ["dpright"]="G_DPAD_RIGHT"
}

Lynput.s_gamepadAxes = {
  ["leftx"]="G_LEFTSTICK_X", ["lefty"]="G_LEFTSTICK_Y",
  ["rightx"]="G_RIGHTSTICK_X", ["righty"]="G_RIGHTSTICK_Y",
  ["triggerleft"]="G_LT", ["triggerright"]="G_RT"
}

-----------------------
-- FUTURE DICTIONARIES
-----------------------
-- Lynput.s_mouse_axes = {
--   "wd", "wu"
-- }


function Lynput:new()
  -- Maps Lynput inputs and states to actions, inputsSet[state][action]
  self.inputsSet = {}

  -- TODO: Test gamepad support with more than 1 gamepad
  self.gpad = nil
  -- TODO: set and get dead zone
  -- TODO: Different deadzones for joysticks and triggers
  self.gpadDeadZone = 30
  
  self.id = tostring(Lynput.s_idCount)
  Lynput.s_lynputs[self.id] = self
  Lynput.s_idCount = Lynput.s_idCount + 1
  Lynput.s_count = Lynput.s_count + 1
end


function Lynput.update_(dt)
  for _, lynput in pairs(Lynput.s_lynputs) do
    lynput:update(dt)
  end -- for each lynput
end


local function _isActionValid(action)
  if type(action) ~= "string" then
    return false
  end -- if not string
  
  for _, reservedName in ipairs(Lynput.s_reservedNames) do
    if reservedName == action then
      return false
    end -- if action name is reserved
  end -- for each reserved name

  for _, reservedChar in ipairs(Lynput.s_reservedCharacters) do
    if string.find(action, reservedChar) then
      return false
    end -- if action name contains reserved characters
  end -- for each reserved character

  return true
end


local function _isCommandValid(command)
  local stateValid, inputValid = false, false
  local state, input = string.match(command, "(.+)%s(.+)")
  
  if not state or not input then
    goto exit
  end -- if state or input are nil
  
  -- Process state
  stateValid =
    state == "release" or
    state == "press" or
    state == "hold"

  if not stateValid then
    local min, max = string.match(state, "(.+)%:(.+)")

    min = tonumber(min)
    max = tonumber(max)

    if not min or not max then
      goto exit
    end -- if min or max are nil

    stateValid =
      min < max and
      min >= -100 and
      max <= 100
  end -- if state is not meant for buttons

  -- Process input
  for _, button in pairs(Lynput.s_mouseButtons) do
    if button == input then
      inputValid = true
      goto exit
    end -- if button == input
  end -- for each Lynput mouse button
  
  for _, button in pairs(Lynput.s_gamepadButtons) do
    if button == input then
      inputValid = true
      goto exit
    end -- if button == input
  end -- for each Lynput gamepad button
  
  for _, axis in pairs(Lynput.s_gamepadAxes) do
    if axis == input then
      inputValid = true
      goto exit
    end -- if axis == input
  end -- for each Lynput gamepad axis

  -- TODO: Touch screen
  
  inputValid = pcall(love.keyboard.getScancodeFromKey, input)

  ::exit::

  return stateValid and inputValid, state, input
end


function Lynput:remove()
  Lynput.s_lynputs[self.id] = nil
  Lynput.s_count = Lynput.s_count - 1
end


-- @param gamepad is a Lynput gamepad string name (e.g., "GPAD_1", "GPAD_2", ..., "GPAD_N")
function Lynput:attachGamepad(gamepad)
  -- TODO: More code, this needs to detach previous Lynput gamepad
  
  self.gpad = gamepad
end


function Lynput:bind(action, commands)
  -- Transforms 1 input to a table
  if type(commands) == "string" then
    local command = commands
    commands = {}
    commands[1] = command
  end -- if only one command was given

  -- Process command
  for _, command in ipairs(commands) do
    -- Is action valid?
    assert(
      _isActionValid(action),
      "Could not bind command->" .. command ..
      -- TODO: Check documentation for valid actions message
	"  to action->" .. action .. ", the action is not valid."
    )
    -- Is command valid?
    local commandValid, state, input = _isCommandValid(command)
    assert(
      commandValid,
      "Could not bind command->" .. command ..
	"  to action->" .. action .. ", the command is not valid." ..
	"\n\nCommands should be formated as follows: \n\n" ..
	"    COMMAND = STATE INPUT (with a space in between)\n" ..
	"    STATE =\n" ..
        "        for buttons -> press, release or hold\n" ..
	"        for analog inputs -> x:y (with a colon in between) where x and y are numbers\n" ..
	"    INPUT = check the manual for all availible inputs\n\n"
    )

    if self[action] == nil then
      self[action] = false
    end -- if action not set

    if not self.inputsSet[input] then
      self.inputsSet[input] = {}
    end -- if input hasn't already been set

    self.inputsSet[input][state] = action
  end -- for each command
end


function Lynput:unbind(action, commands)
  -- Transforms 1 command to a table
  if type(commands) == "string" then
    local command = commands
    commands = {}
    commands[1] = command
  end -- if only one command was given

  -- Process command
  for _, command in ipairs(commands) do
    -- Is action set?
    -- FIXME: Exception when indexing nil values are not being handled, fix everywhere
    assert(
      self[action] ~= nil,
      "Could not unbind command->" .. command .. 
	"  to action->" .. action .. ", the action is not set."
    )
    -- Is command set?
    local state, input = string.match(command, "(.+)%s(.+)")
    assert(
      self.inputsSet[input][state],
      "Could not unbind command->" .. command .. 
	"  to action->" .. action .. ", the command is not set."
    )
    
    self.inputsSet[input][state] = nil
    local inputStates = self.inputsSet[input]

    local statesNum = 0
    for state, _ in pairs(self.inputsSet[input]) do
      statesNum = statesNum + 1
    end -- for each state

    if statesNum == 0 then
      self.inputsSet[input] = nil
    end -- if there are no more states set

    self[action] = false
  end -- for each command
end


function Lynput:unbindAll(action)
  -- Is action set?
  assert(
    self[action] ~= nil,
    "Could not unbind all commands in action->" .. action ..
      ", the action is not set."
  )

  for inputSet, states in pairs(self.inputsSet) do
    for state, actionSet in pairs(states) do
      if actionSet == action then
	self.inputsSet[inputSet][state] = nil
      end -- if actionSet == action
    end -- for each inputSet state
  end -- for each input set
  
  self[action] = false
end


function Lynput:removeAction(action)
  -- Is action set?
  assert(
    self[action] ~= nil,
    "Could not remove action->" .. action ..
      ", this action does not exist."
  )
  
  self:unbindAll(action)
  self[action] = nil
end


function Lynput:update(dt)
  -- It's not possible to iterate actions through "self" because it
  -- also contains the inputsSet table and other data
  for _, states in pairs(self.inputsSet) do
    for state, actionSet in pairs(states) do
      if state == "press" or state == "release" then
	self[actionSet] = false
      end -- if state ~= hold
    end -- for each state
  end -- for each input set

  if Lynput[self.gpad] then
    for loveAxis, lynputAxis in pairs(Lynput.s_gamepadAxes) do
    if self.inputsSet[lynputAxis] then
      local val = Lynput[self.gpad]:getGamepadAxis(loveAxis) * 100
      
      for interval, action in pairs(self.inputsSet[lynputAxis]) do
	local min, max = string.match(interval, "(.+)%:(.+)")
	min = tonumber(min)
	max = tonumber(max)
	if val >= min and (math.abs(val) > self.gpadDeadZone) and val <= max then
	  self[action] = true
	end -- if val is in interval
      end -- for each interval
    end -- if the axis is set
    end -- for each axis
  end -- if the gamepad has been added
end


---------------------------------
-- KEYBOARD CALLBACKS
---------------------------------
function Lynput.onkeypressed(key)
  for _, lynput in pairs(Lynput.s_lynputs) do
    if lynput.inputsSet[key] then
      if lynput.inputsSet[key]["press"] then
	local action = lynput.inputsSet[key]["press"]
	lynput[action] = true
      end -- if press_key is set
      if lynput.inputsSet[key]["hold"] then
	local action = lynput.inputsSet[key]["hold"]
	lynput[action] = true
      end -- if hold_key is set      
    end -- if key set
  end -- for each lynput
end


function Lynput.onkeyreleased(key)
  for _, lynput in pairs(Lynput.s_lynputs) do
    if lynput.inputsSet[key] then
      if lynput.inputsSet[key]["release"] then
	local action = lynput.inputsSet[key]["release"]
	lynput[action] = true
      end -- if release_key is set
      if lynput.inputsSet[key]["hold"] then
	local action = lynput.inputsSet[key]["hold"]
	lynput[action] = false
      end -- if hold_key is set
    end -- if key is set
  end -- for each lynput
end


--------------------------------------
-- MOUSE CALLBACKS
--------------------------------------
function Lynput.onmousepressed(button)
  -- Translate LÖVE button to Lynput button
  button = Lynput.s_mouseButtons[tostring(button)]
  -- Process button
  for _, lynput in pairs(Lynput.s_lynputs) do
    if lynput.inputsSet[button] then
      if lynput.inputsSet[button]["press"] then
	local action = lynput.inputsSet[button]["press"]
	lynput[action] = true
      end -- if press_button is set
      if lynput.inputsSet[button]["hold"] then
	local action = lynput.inputsSet[button]["hold"]
	lynput[action] = true
      end -- if hold_button is set
    end -- if button is set
  end -- for each lynput
end


function Lynput.onmousereleased(button)
    -- Translate LÖVE button to Lynput button
  button = Lynput.s_mouseButtons[tostring(button)]
  -- Process button
  for _, lynput in pairs(Lynput.s_lynputs) do
    if lynput.inputsSet[button] then
      if lynput.inputsSet[button]["release"] then
	local action = lynput.inputsSet[button]["release"]
	lynput[action] = true
      end -- if press_button is set
      if lynput.inputsSet[button]["hold"] then
	local action = lynput.inputsSet[button]["hold"]
	lynput[action] = false
      end -- if hold_button is set
    end -- if button is set
  end -- for each lynput
end


---------------------------------------------------
-- GAMEPAD CALLBACKS
---------------------------------------------------
function Lynput.ongamepadpressed(gamepadID, button)
  -- Translate LÖVE button to Lynput button
  button = Lynput.s_gamepadButtons[button]
  -- Process Lynput button
  for _, lynput in pairs(Lynput.s_lynputs) do
    if lynput.gpad then
      if Lynput[lynput.gpad]:getID() == gamepadID then
	if lynput.inputsSet[button] then
	  if lynput.inputsSet[button]["press"] then
	    local action = lynput.inputsSet[button]["press"]
	    lynput[action] = true
	  end -- if press_button is set
	  if lynput.inputsSet[button]["hold"] then
	    local action = lynput.inputsSet[button]["hold"]
	    lynput[action] = true
	  end -- if hold_button is set
	end -- if button is set
      end -- if gamepad is set
    end -- if lynput has a gamepad attached
  end -- for each lynput
end


function Lynput.ongamepadreleased(gamepadID, button)
  -- Translate LÖVE button to Lynput button
  button = Lynput.s_gamepadButtons[button]
  -- Process Lynput button
  for _, lynput in pairs(Lynput.s_lynputs) do
    if lynput.gpad then
      if Lynput[lynput.gpad]:getID() == gamepadID then
	if lynput.inputsSet[button] then
	  if lynput.inputsSet[button]["release"] then
	    local action = lynput.inputsSet[button]["release"]
	    lynput[action] = true
	  end -- if release_button is set
	  if lynput.inputsSet[button]["hold"] then
	    local action = lynput.inputsSet[button]["hold"]
	    lynput[action] = false
	  end -- if hold_button is set
	end -- if button is set
      end -- if gamepad is set
    end -- if lynput has a gamepad attached
  end -- for each lynput
end


function Lynput.ongamepadadded(gamepad)
  local gamepadID = gamepad:getID()
  local i = 1
  local gpad = "GPAD_1"
  while Lynput[gpad] do
    if Lynput[gpad]:getID() == gamepadID then
      return
    end -- if gamepadID is already assgined
    
    i = i +1
    gpad = "GPAD_" .. i
  end -- while gpad exists

  -- gpad does no exists, so we assign the new gamepad to it
  Lynput[gpad] = gamepad
end
