-- Camera transforms.

local graphics = love.graphics

local Object = require "object"
local Rect = require "rect"
local Vec = require "vec"

---

--- @class Camera: Object
local Camera = Object:inherit()

--- The scaling factor for rendering things with the camera.
Camera.scale = 4

--- Initializes a new camera.
function Camera:init()
  self.pan = Vec(0, 0)
  self.viewportSize = Vec(graphics.getDimensions())
end

--- Updates the viewport size of the camera.
---
--- @param size Vec
function Camera:updateViewport(size)
  self.viewportSize = size
end

--- Adds the specified panning to the camera's panning.
---
--- @param pan Vec
function Camera:applyPan(pan)
  self.pan = self.pan + pan
end

--- Returns a Rect containing the visible area of the camera.
---
--- @return Rect
function Camera:viewport()
  local halfWidth, halfHeight = (self.viewportSize / (2 * Camera.scale)):xy()
  local x, y = self.pan:xy()
  return Rect.sides {
    left = x - halfWidth,
    right = x + halfWidth,
    top = y - halfHeight,
    bottom = y + halfHeight,
  }
end

--- Transforms the view to the camera's view, executes fn, and resets the
--- transform.
--- Any arguments following are passed to the fn.
---
--- @param fn function
--- @vararg  Passed to fn.
function Camera:transform(fn, ...)
  local width, height = self.viewportSize:xy()
  local pan = self.pan * Camera.scale
  graphics.push()
  graphics.translate(width / 2, height / 2)
  graphics.translate(-pan.x, -pan.y)
  graphics.scale(Camera.scale)
  fn(...)
  graphics.pop()
end

--- Converts a point from screen space to world space.
---
--- @param point Vec
function Camera:toWorldSpace(point)
  return (point - self.viewportSize / 2) / Camera.scale + self.pan
end

return Camera
