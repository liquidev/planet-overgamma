-- Fast 2D vector, requires LuaJIT (which is what LÖVE uses anyways).
-- If you're not using LuaJIT somehow, congration! _You really should_.

local ffi = require "ffi"

ffi.cdef [[
  typedef struct {
    float x, y;
  } Vec;
]]

local vecMeta = {}
local Vec

-- Returns the vector with its components negated.
function vecMeta:__unm()
  return Vec(-self.x, -self.y)
end

-- Adds two vectors together.
function vecMeta:__add(other)
  return Vec(self.x + other.x, self.y + other.y)
end

-- Subtracts the other vector from this vector.
function vecMeta:__sub(other)
  return Vec(self.x - other.x, self.y - other.y)
end

-- Multiplies the vector by a number, or does component-wise multiplication
-- of self and other.
function vecMeta:__mul(op)
  if type(op) == "number" then
    return Vec(self.x * op, self.y * op)
  else
    return Vec(self.x * op.x, self.y * op.y)
  end
end

-- Divides the vector by a number, or does component-wise division
-- of self and other.
function vecMeta:__div(op)
  if type(op) == "number" then
    return Vec(self.x / op, self.y / op)
  else
    return Vec(self.x / op.x, self.y / op.y)
  end
end

-- Converts the vector to a string.
function vecMeta:__tostring()
  return string.format("Vec(%.2f, %.2f)", self.x, self.y)
end

local vecMethods = {}
vecMeta.__index = vecMethods

-- Returns the dot product of this vector and the other vector.
function vecMethods:dot(other)
  return self.x * other.x + self.y * other.y
end

-- Returns the squared length of this vector.
function vecMethods:len2()
  return self:dot(self)
end

-- Returns the length of this vector.
function vecMethods:len()
  return math.sqrt(self:len2())
end

-- Returns this vector, but normalized: its components are divided by its
-- length. This yields a unit vector.
-- This also returns the length of the vector before normalization.
function vecMethods:normalized()
  local len = self:len()
  return self / len, len
end

Vec = ffi.metatype("Vec", vecMeta)

return Vec

