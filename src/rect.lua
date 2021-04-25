-- Axis-aligned rectangle.

local Vec = require "vec"

---

local Rect = {}
Rect.__index = Rect
Rect.__name = "Rect"

-- Indexes the rect.
-- This enables the x, y, width, height fields.
function Rect:__index(key)
  if Rect[key] ~= nil then
    return Rect[key]
  end
  if self[key] ~= nil then
    return self[key]
  end
  if key == "x" then return self.position.x
  elseif key == "y" then return self.position.y
  elseif key == "width" then return self.size.x
  elseif key == "height" then return self.size.y
  end
end

-- Creates and initializes a new rectangle with:
-- a) the provided X, Y position, width, and height - Rect:new(x, y, w, h)
-- b) the provided position vec and size vec - Rect:new(position, size)
function Rect:new(x, y, w, h)
  local r = setmetatable({}, self)
  if w and h then
    r.position = Vec(x, y)
    r.size = Vec(w, h)
  else
    r.position = x
    r.size = y
  end
  return r
end

-- Returns a string representation of the rectangle.
function Rect:__tostring()
  return string.format("Rect(%s, %s)", self.position, self.size)
end

return Rect
