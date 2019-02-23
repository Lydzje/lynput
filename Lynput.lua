--
-- Lynput
--
-- Copyright (c) 2019, Lydzje
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--

local Lynput = {}
local chordMatchExpression = "%+?([^%+]+)%+?"
Lynput.__index = Lynput

setmetatable(
  Lynput,
    {
      __call = function (cls, ...)
	return cls.new(...)
      end,
    }
)

Lynput.s_lynputs = {}
Lynput.s_idCount = 0
Lynput.s_count = 0

Lynput.s_reservedNames = {
  -- Reserved by Lua
  "and", "break", "do", "else", "elseif", "end", "false", "for", 
  "function", "if", "in", "local", "nil", "not", "or", "repeat", 
  "return", "then", "true", "until", "while",
  -- Reserved by Lynput
  "inputsSet", "chordsSet", "chordInput", "gpad", "gpadDeadZone", "id", "remove", "attachGamepad",
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


function Lynput.new()
  local self = setmetatable({}, Lynput)
  -- Maps Lynput inputs and states to actions, inputsSet[state][action]
  self.inputsSet = {}
  -- Maps Lynput chords and states to actions, chordsSet[state][action]
  self.chordsSet = {}
  self.chordInputs = {}

  self.gpad = nil
  -- TODO: Different deadzones for joysticks and triggers
  self.gpadDeadZone = 30
  
  self.id = tostring(Lynput.s_idCount)
  Lynput.s_lynputs[self.id] = self
  Lynput.s_idCount = Lynput.s_idCount + 1
  Lynput.s_count = Lynput.s_count + 1

  return self
end


function Lynput.load_key_callbacks()
  function love.keypressed(key) Lynput.onkeypressed(key) end
  function love.keyreleased(key) Lynput.onkeyreleased(key) end
end


function Lynput.load_mouse_callbacks()
  function love.mousepressed(x, y, button, istouch) Lynput.onmousepressed(button) end
  function love.mousereleased(x, y, button, istouch) Lynput.onmousereleased(button) end
end


function Lynput.load_gamepad_callbacks()
  function love.gamepadpressed(joystick, button) Lynput.ongamepadpressed(joystick:getID(), button) end
  function love.gamepadreleased(joystick, button) Lynput.ongamepadreleased(joystick:getID(), button) end
  function love.joystickadded(joystick) Lynput.ongamepadadded(joystick) end
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
    if string.find(action, "%" .. reservedChar) then
      return false
    end -- if action name contains reserved characters
  end -- for each reserved character

  return true
end

local function _isInputValid(input)
  local inputValid = false
  local inputs = {}

  if(string.match(input, chordMatchExpression))then
    for match in string.gmatch(input, chordMatchExpression)do
      table.insert(inputs, match)
    end
  else
    table.insert(inputs, input)
  end

  -- Process input
  for _,input in pairs(inputs) do
    if input == "any" then
      if(#inputs > 1)then
        inputValid = false
      else
        inputValid = true
      end

      return inputValid
    end -- if input == any
    
    for _, button in pairs(Lynput.s_mouseButtons) do
      if button == input then
        inputValid = true
        if #inputs == 1 then
          return inputValid
        end
        break
      end -- if button == input
    end -- for each Lynput mouse button
    
    for _, button in pairs(Lynput.s_gamepadButtons) do
      if button == input then
        inputValid = true
        if #inputs == 1 then
          return inputValid
        end
        break
      end -- if button == input
    end -- for each Lynput gamepad button
    
    for _, axis in pairs(Lynput.s_gamepadAxes) do
      if axis == input then
        inputValid = true
        if #inputs == 1 then
          return inputValid
        end
        break
      end -- if axis == input
    end -- for each Lynput gamepad axis

    if(not inputValid)then
      inputValid = pcall(love.keyboard.getScancodeFromKey, input)
    end

    if(not inputValid)then
      break
    end
  end
  -- TODO: Touch screen
  return inputValid
end

local function _isCommandValid(command)
  local stateValid, inputValid = false, false
  local state, input = string.match(command, "(.+)%s(.+)")
  
  if not state or not input then
    return stateValid and inputValid, state, input
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
      return stateValid and inputValid, state, input
    end -- if min or max are nil

    stateValid =
      min < max and
      min >= -100 and
      max <= 100
  end -- if state is not meant for buttons

  inputValid = _isInputValid(input)

  return stateValid and inputValid, state, input
end

function Lynput:remove()
  Lynput.s_lynputs[self.id] = nil
  Lynput.s_count = Lynput.s_count - 1
end


-- @param gamepad is a Lynput gamepad string name (e.g., "GPAD_1", "GPAD_2", ..., "GPAD_N")
function Lynput:attachGamepad(gamepad)
  -- TODO: More code, this needs to check if the parameter given is like expected
  
  self.gpad = gamepad
end


function Lynput:getAxis(axis)
  for loveAxis, lynputAxis in pairs(Lynput.s_gamepadAxes) do
    if axis == loveAxis or axis == lynputAxis then
      return Lynput[self.gpad]:getGamepadAxis(loveAxis) * 100
    end
  end

  error(
    "Axis->" .. axis .. " is not a valid name. Use LÖVE or Lynput names for axes."
  )
end


function Lynput:bind(action, commands)  
  -- Type checking for argument #1
  assert(
    type(action) == "string",
    "bad argument #1 to 'Lynput:bind' (string expected, got " .. type(action) .. ")" ..
      "\nCheck the stack traceback to know where the invalid arguments have been passed"
  )
  
  -- Transforms 1 command to a table
  if type(commands) ~= "table" then
    local command = commands
    commands = {}
    commands[1] = command
  end -- if only one command was given

  -- Type checking for argument #2
  for i, command in ipairs(commands) do
    assert(
      type(command) == "string",
      "bad argument #2 to 'Lynput:bind' (string or table of strings expected, got " ..
	type(command) .. " in element #" .. i .. ")" ..
	"\nCheck the stack traceback to know where the invalid arguments have been passed"
    )
  end -- for each element in commands table

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
    -- TODO: Use a "check the manual for commands format" instead of explaining it here
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

    if(not string.match(input, ".+%+.+"))then
      if not self.inputsSet[input] then
        self.inputsSet[input] = {}
      end -- if input hasn't already been set

      self.inputsSet[input][state] = action
    else
      if not self.chordsSet[input] then
        self.chordsSet[input] = {}
      end

      self.chordsSet[input][state] = action
      self.chordInputs[state] = {}

      for chordInput in string.gmatch(input, chordMatchExpression)do
        self.chordInputs[state][chordInput] = false
      end
    end
  end -- for each command
end


function Lynput:unbind(action, commands)
  -- Type checking for argument #1
  assert(
    type(action) == "string",
    "bad argument #1 to 'Lynput:unbind' (string expected, got " .. type(action) .. ")" ..
      "\nCheck the stack traceback to know where the invalid arguments have been passed"
  )
  
  -- Transforms 1 command to a table
  if type(commands) ~= "table" then
    local command = commands
    commands = {}
    commands[1] = command
  end -- if only one command was given

  -- Type checking for argument #2
  for i, command in ipairs(commands) do
    assert(
      type(command) == "string",
      "bad argument #2 to 'Lynput:unbind' (string or table of strings expected, got " ..
	type(command) .. " in element #" .. i .. ")" ..
	"\nCheck the stack traceback to know where the invalid arguments have been passed"
    )
  end -- for each element in commands table
  
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
    
    if(not string.match(input, chordMatchExpression)) then
      self.inputsSet[input][state] = nil

      local statesNum = 0
      for state, _ in pairs(self.inputsSet[input]) do
        statesNum = statesNum + 1
      end -- for each state

      if statesNum == 0 then
        self.inputsSet[input] = nil
      end -- if there are no more states set

      self[action] = false
    else
      self.chordsSet[input][state] = nil

      local statesNum = 0
      for state, _ in pairs(self.chordsSet[input]) do
        statesNum = statesNum + 1
      end -- for each state

      if statesNum == 0 then
        self.chordsSet[input] = nil
      end -- if there are no more states set

      self[action] = false
    end
  end -- for each command
end


function Lynput:unbindAll(action)
  -- Type checking for argument #1
  assert(
    type(action) == "string",
    "bad argument #1 to 'Lynput:unbindAll' (string expected, got " .. type(action) .. ")" ..
      "\nCheck the stack traceback to know where the invalid arguments have been passed"
  )
  
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
  for chordSet, states in pairs(self.chordsSet) do
    for state, actionSet in pairs(states) do
      if actionSet == action then
        self.chordsSet[chordSet][state] = nil
      end -- if actionSet == action
    end -- for each chordSet state
  end -- for each input set
  self[action] = false
end


function Lynput:removeAction(action)
  -- Type checking for argument #1
  assert(
    type(action) == "string",
    "bad argument #1 to 'Lynput:removeAction' (string expected, got " .. type(action) .. ")" ..
      "\nCheck the stack traceback to know where the invalid arguments have been passed"
  )
  
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

  for _, states in pairs(self.chordsSet) do
    for state, actionSet in pairs(states) do
      if state == "press" or state == "release" then
       self[actionSet] = false
      end -- if state ~= hold
    end -- for each state
  end -- for each input set

-- chordsSet[chord][actionState][inputKey]
  for state,inputs in pairs(self.chordInputs) do
    for input,_ in pairs(inputs) do
      if(state == 'press' or state == 'release')then
        self.chordInputs[state][input] = false
      end
    end
  end

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
	  else
	    self[action] = false
	  end -- if val is in interval
	end -- for each interval
      end -- if the axis is set
    end -- for each axis
  end -- if the gamepad has been added
end

local function setInputState(lynput, input, inputAction, desiredState)
  if lynput.inputsSet[input] then
      if lynput.inputsSet[input][inputAction] then
        local action = lynput.inputsSet[input][inputAction]
        lynput[action] = desiredState
      end -- if inputAction input (e.g. press_key) is set
    end -- if input set
end

local function setChordState(lynput, input, inputAction, desiredState)
  for action, _ in pairs(lynput.chordInputs) do
    if(action == inputAction) then
      lynput.chordInputs[action][input] = desiredState
    end
  end -- for each registered action

  for chord, actions in pairs(lynput.chordsSet) do
    if(string.match(chord, input))then
      local cumulativeState = desiredState
      for actionState, _ in pairs(actions) do
        for chordInput in string.gmatch(chord, chordMatchExpression) do
          print(chordInput, lynput.chordInputs[inputAction][chordInput])
          if(not (lynput.chordInputs[inputAction][chordInput] == desiredState))then
            cumulativeState = not desiredState
            break
          end
        end

        if(lynput.chordsSet[chord][inputAction])then
          local action = lynput.chordsSet[chord][inputAction]
          lynput[action] = cumulativeState
        end
      end
    end -- if chord contains input
  end -- for each registered chord
end

---------------------------------
-- KEYBOARD CALLBACKS
---------------------------------
function Lynput.onkeypressed(key)
  for _, lynput in pairs(Lynput.s_lynputs) do
    setInputState(lynput, 'any', 'press', true)
    setInputState(lynput, 'any', 'hold', true)

    setInputState(lynput, key, 'press', true)
    setInputState(lynput, key, 'hold', true)

    setChordState(lynput, key, 'press', true)
    setChordState(lynput, key, 'hold', true)
  end -- for each lynput
end


function Lynput.onkeyreleased(key)
  for _, lynput in pairs(Lynput.s_lynputs) do
    setInputState(lynput, 'any', 'release', true)
    setInputState(lynput, 'any', 'hold', false)

    setInputState(lynput, key, 'release', true)
    setInputState(lynput, key, 'hold', false)

    setChordState(lynput, key, 'release', true)
    setChordState(lynput, key, 'hold', false)
  end
end


--------------------------------------
-- MOUSE CALLBACKS
--------------------------------------
function Lynput.onmousepressed(button)
  -- Translate LÖVE button to Lynput button
  button = Lynput.s_mouseButtons[tostring(button)]
  -- Process button
  for _, lynput in pairs(Lynput.s_lynputs) do
    setInputState(lynput, 'any', 'press', true)
    setInputState(lynput, 'any', 'hold', true)

    setInputState(lynput, button, 'press', true)
    setInputState(lynput, button, 'hold', true)

    setChordState(lynput, button, 'press', true)
    setChordState(lynput, button, 'hold', true)
  end -- for each lynput
end


function Lynput.onmousereleased(button)
  -- Translate LÖVE button to Lynput button
  button = Lynput.s_mouseButtons[tostring(button)]
  -- Process button
  for _, lynput in pairs(Lynput.s_lynputs) do
    setInputState(lynput, 'any', 'release', true)
    setInputState(lynput, 'any', 'hold', false)

    setInputState(lynput, button, 'release', true)
    setInputState(lynput, button, 'hold', false)

    setChordState(lynput, button, 'release', true)
    setChordState(lynput, button, 'hold', false)
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
      setInputState(lynput, 'any', 'press', true)
      setInputState(lynput, 'any', 'hold', true)

	    setInputState(lynput, button, 'press', true)
      setInputState(lynput, button, 'hold', true)

      setChordState(lynput, button, 'press', true)
      setChordState(lynput, button, 'hold', true)
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
	      setInputState(lynput, 'any', 'release', true)
        setInputState(lynput, 'any', 'hold', false)

        setInputState(lynput, button, 'release', true)
        setInputState(lynput, button, 'hold', false)

        setChordState(lynput, button, 'release', true)
        setChordState(lynput, button, 'hold', false)
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
    end -- if gamepadID is already assigned
    
    i = i +1
    gpad = "GPAD_" .. i
  end -- while gpad exists

  -- gpad does no exists, so we assign the new gamepad to it
  Lynput[gpad] = gamepad
end


return Lynput
