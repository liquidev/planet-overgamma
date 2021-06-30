-- Fast 2D vector, requires LuaJIT (which is what LÖVE uses anyways).
-- If you're not using LuaJIT somehow, congration! _You really should_.

local ffi = require "ffi"

local common = require "common"

---

ffi.cdef [[
  typedef struct {
    float x, y;
  } Vec;
]]

local vecMeta = {}

--- @class Vec
--- @field x number
--- @field y number
local Vec = ffi.metatype("Vec", vecMeta)

--- Returns the vector with its components negated.
function vecMeta:__unm()
  return Vec(-self.x, -self.y)
end

--- Adds two vectors together.
function vecMeta:__add(other)
  return Vec(self.x + other.x, self.y + other.y)
end

--- Subtracts the other vector from this vector.
function vecMeta:__sub(other)
  return Vec(self.x - other.x, self.y - other.y)
end

--- Multiplies the vector by a number, or does component-wise multiplication
--- of self and other.
function vecMeta:__mul(op)
  if type(op) == "number" then
    return Vec(self.x * op, self.y * op)
  else
    return Vec(self.x * op.x, self.y * op.y)
  end
end

--- Divides the vector by a number, or does component-wise division
--- of self and other.
function vecMeta:__div(op)
  if type(op) == "number" then
    return Vec(self.x / op, self.y / op)
  else
    return Vec(self.x / op.x, self.y / op.y)
  end
end

--- Converts the vector to a string.
function vecMeta:__tostring()
  return string.format("Vec(%.2f, %.2f)", self.x, self.y)
end

local vecMethods = {}
vecMeta.__index = vecMethods

--- Duplicates the vector.
function vecMethods:dup()
  return Vec(self.x, self.y)
end

--- Returns the x, y coordinates of the vector as two values.
function vecMethods:xy()
  return self.x, self.y
end

--- Adds a vector to the provided vector in place.
function vecMethods:add(other)
  self.x = self.x + other.x
  self.y = self.y + other.y
end

--- Subtracts a vector from the provided vector in place.
function vecMethods:sub(other)
  self.x = self.x - other.x
  self.y = self.y - other.y
end

--- Multiplies the vector by a scalar or a vector in place.
function vecMethods:mul(op)
  if type(op) == "number" then
    self.x = self.x * op
    self.y = self.y * op
  else
    self.x = self.x * op.x
    self.y = self.y * op.y
  end
end

--- Divides the vector by a scalar or a vector in place.
function vecMethods:div(op)
  if type(op) == "number" then
    self.x = self.x / op
    self.y = self.y / op
  else
    self.x = self.x / op.x
    self.y = self.y / op.y
  end
end

--- Zeroes the given vector in place.
function vecMethods:zero()
  self.x = 0
  self.y = 0
end

--- Copies another vector into the vector.
function vecMethods:copy(other)
  self.x = other.x
  self.y = other.y
end

--- Sets the vector's coordinates in place.
function vecMethods:set(x, y)
  self.x = x
  self.y = y
end

--- Returns the dot product of this vector and the other vector.
function vecMethods:dot(other)
  return self.x * other.x + self.y * other.y
end

--- Returns the squared length of this vector.
function vecMethods:len2()
  return self:dot(self)
end

--- Returns the length of this vector.
function vecMethods:len()
  return math.sqrt(self:len2())
end

--- Returns this vector, but normalized: its components are divided by its
--- length. This yields a unit vector.
--- This also returns the length of the vector before normalization.
function vecMethods:normalized()
  local len = self:len()
  if len == 0 then
    return Vec(0, 0), len
  else
    return self / len, len
  end
end

--- Returns a copy of the vector with its components floored.
function vecMethods:floor()
  return Vec(math.floor(self.x), math.floor(self.y))
end

--- Returns a copy of the vector with its components ceil'd.
function vecMethods:ceil()
  return Vec(math.ceil(self.x), math.ceil(self.y))
end

--- Returns a copy of the vector with its components rounded.
function vecMethods:round()
  return Vec(common.round(self.x), common.round(self.y))
end

--- Linearly interpolates between this vector and the other vector, with
--- the given interpolation factor.
local lerp = common.lerp
function vecMethods:lerp(other, t)
  -- Doing this per-component allows LuaJIT to optimize this better, as fewer
  -- metatable accesses are involved.
  return Vec(
    lerp(self.x, other.x, t),
    lerp(self.y, other.y, t)
  )
end

--- Creates a vector from an angle.
function vecMethods.fromAngle(angle)
  return Vec(math.cos(angle), math.sin(angle))
end

return Vec

