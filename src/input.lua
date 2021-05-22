-- Generic input handler that's More Convenient Than Events.™
--
-- I generally dislike events, mainly for the fact that they seem to needlessly
-- complicate code with callbacks, and I don't find them suitable for quick
-- game development. This input wrapper takes events and converts them into
-- a single input state object that can later be polled by individual parts
-- of the game.

local Object = require "object"
local Vec = require "vec"

---

local Input = Object:inherit()

-- mouse buttons
Input.mbLeft = 1
Input.mbRight = 2
Input.mbMiddle = 3

-- Initializes a new input state instance.
function Input:init()
  -- mouse cursor
  self.mouse = Vec(0, 0)
  self.previousMouse = Vec(0, 0)
  self.deltaMouse = Vec(0, 0)
  self.deltaScroll = Vec(0, 0)

  -- mouse buttons
  self.mouseButtonsDown = {}
  self.mouseButtonsJustPressed = {}
  self.mouseButtonsJustReleased = {}

  -- keyboard
  self.keysDown = {}
  self.keysJustPressed = {}
  self.keysJustReleased = {}
end

-- Processes a single event and updates input state accordingly.
function Input:processEvent(event)
  -- mouse position
  if event.kind == "mousemoved" then
    local x, y = unpack(event)
    self.mouse = Vec(x, y)
    self.deltaMouse = self.mouse - self.previousMouse
  end

  -- scroll wheel
  if event.kind == "wheelmoved" then
    local x, y = unpack(event)
    self.deltaScroll:add(Vec(x, y))
  end

  -- mouse button events
  if event.kind == "mousepressed" or event.kind == "mousereleased" then
    local button = event[3]
    if event.kind == "mousepressed" then
      self.mouseButtonsDown[button] = true
      self.mouseButtonsJustPressed[button] = true
    else
      self.mouseButtonsJustReleased[button] = true
      self.mouseButtonsDown[button] = nil
    end
  end

  -- key events
  if event.kind == "keypressed" or event.kind == "keyreleased" then
    local _, scancode, isRepeat = unpack(event)
    if not isRepeat then
      if event.kind == "keypressed" then
        self.keysJustPressed[scancode] = true
        self.keysDown[scancode] = true
      else
        self.keysJustReleased[scancode] = true
        self.keysDown[scancode] = nil
      end
    end
  end
end

-- Updates the input state for the next frame.
function Input:finishFrame()
  -- mouse position
  self.previousMouse = self.mouse
  self.deltaScroll:zero()

  -- reset momentary mouse events
  self.mouseButtonsJustPressed = {}
  self.mouseButtonsJustReleased = {}

  -- reset momentary key events
  self.keysJustPressed = {}
  self.keysJustReleased = {}
end

-- Returns whether a mouse button is being held.
function Input:mouseDown(button)
  return self.mouseButtonsDown[button] ~= nil
end

-- Returns whether a mouse button has just been pressed.
function Input:mouseJustPressed(button)
  return self.mouseButtonsJustPressed[button] ~= nil
end

-- Returns whether a mouse button has just been released.
function Input:mouseJustReleased(button)
  return self.mouseButtonsJustReleased[button] ~= nil
end

-- Returns whether a key is being held.
function Input:keyDown(scancode)
  return self.keysDown[scancode] ~= nil
end

-- Returns whether a key has just been pressed.
function Input:keyJustPressed(scancode)
  return self.keysJustPressed[scancode] ~= nil
end

-- Returns whether a key has just been released.
function Input:keyJustReleased(scancode)
  return self.keysJustReleased[scancode] ~= nil
end

return Input
