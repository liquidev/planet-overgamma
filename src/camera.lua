-- Camera transforms.

local graphics = love.graphics

local Object = require "object"
local Vec = require "vec"

---

local Camera = Object:inherit()

-- The scaling factor for rendering things with the camera.
Camera.scale = 3

-- Initializes a new camera.
function Camera:init()
  self.pan = Vec(0, 0)
end

-- Adds the specified panning to the camera's panning.
function Camera:applyPan(pan)
  self.pan = self.pan + pan
end

-- Transforms the view to the camera's view, executes fn, and resets the
-- transform.
-- size (Vec) specifies the size of the viewport, and defaults to the window
-- size.
-- Any arguments following are passed to the fn.
function Camera:transform(fn, size, ...)
  local width, height
  if size == nil then
    width, height = graphics.getDimensions()
  else
    width, height = size:xy()
  end

  local pan = self.pan * Camera.scale
  graphics.push()
  graphics.translate(width / 2, height / 2)
  graphics.translate(math.floor(-pan.x), math.floor(-pan.y))
  graphics.scale(Camera.scale)
  fn(...)
  graphics.pop()
end

return Camera
