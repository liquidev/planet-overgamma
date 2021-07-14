-- Axis-aligned rectangle.

local Object = require "object"
local Vec = require "vec"

---

--- @class Rect: Object
local Rect = Object:inherit()
Rect.__name = "Rect"

--- Creates and initializes a new rectangle with:
--- a) the provided X, Y position, width, and height - Rect:new(x, y, w, h)
--- b) the provided position vec and size vec - Rect:new(position, size)
---
--- @param x number | Vec
--- @param y number | Vec
--- @param w number | nil
--- @param h number | nil
function Rect:init(x, y, w, h)
  if w and h then
    self.x = x
    self.y = y
    self.width = w
    self.height = h
  else
    self.x = x.x
    self.y = x.y
    self.width = y.x
    self.height = y.y
  end
end

--- Creates and initializes a new rectangle from left/top/right/bottom sides.
---
--- @param sides { left: number, top: number, right: number, bottom: number }
--- @return Rect
function Rect.sides(sides)
  return Rect:new(
    sides.left,
    sides.top,
    sides.right - sides.left,
    sides.bottom - sides.top
  )
end

--- Returns the position of the rectangle as a vector.
---
--- @return Vec
function Rect:position()
  return Vec(self.x, self.y)
end

--- Returns the left side of the rectangle.
---
--- @return number
function Rect:left()
  return self.x
end

--- Returns the top side of the rectangle.
---
--- @return number
function Rect:top()
  return self.y
end

--- Returns the right side of the rectangle.
---
--- @return number
function Rect:right()
  return self.x + self.width
end

--- Returns the bottom side of the rectangle.
---
--- @return number
function Rect:bottom()
  return self.y + self.height
end

--- Returns the x, y, width, and height of the rectangle, in that order.
---
--- @return number x
--- @return number y
--- @return number width
--- @return number height
function Rect:xywh()
  return self.x, self.y, self.width, self.height
end

--- Returns whether the rectangle contains the given point.
---
--- @param point Vec
--- @return boolean
function Rect:hasPoint(point)
  return
    point.x >= self.x and point.y >= self.y and
    point.x <= self.x + self.width and point.y <= self.y + self.height
end

--- Returns whether this rectangle intersects the other rectangle.
---
--- @param other Rect
--- @return boolean
function Rect:intersects(other)
  return
    self:left() < other:right() and other:left() < self:right() and
    self:top() < other:bottom() and other:top() < self:bottom()
end

--- Returns a string representation of the rectangle.
---
--- @return string
function Rect:__tostring()
  return string.format(
    "Rect(%.3f, %.3f)[%.1fx%.1f]",
    self.x,
    self.y,
    self.width,
    self.height
  )
end

return Rect
