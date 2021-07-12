-- Utility functions that are used commonly.

local rgba = love.math.colorFromBytes

---

local common = {}

--- @alias Color number[]

--- Does nothing.
function common.noop() end

--- If x is nil, returns default. Otherwise returns x.
--- This is needed in the rare case when a value is a boolean and
--- the `or` operator wouldn't work as intended.
---
--- @param x any
--- @param default any
--- @return any
function common.default(x, default)
  if x == nil then
    return default
  else
    return x
  end
end

--- Better version of pcall that returns an error with a stack traceback.
---
--- Calls fn in "protected mode" - instead of propagating errors that occur
--- inside fn up the stack, it catches them. If no error occurs, returns true
--- alongside all results the original function returned.
--- If an error occured, returns false alongside an error message string,
--- containing the original error converted to a string, along with a
--- stack traceback.
---
--- @param fn function  The function to call.
--- @vararg             Arguments to be passed to the function.
--- @return boolean ok  Whether the function executed successfully.
--- @return any ret     The function's return value, or an error string.
function common.try(fn, ...)
  local args = {...}
  return xpcall(function ()
    return fn(unpack(args))
  end, function (error)
    return debug.traceback(tostring(error))
  end)
end

--- Prepends `level` amount of spaces to each line in the given string.
---
--- @param str string
--- @param level number
--- @return string
function common.indent(str, level)
  local lines = {}
  for line in str:gmatch("[^\n\r]+") do
    table.insert(lines, line)
  end
  local spaces = string.rep(' ', level)
  for i, line in pairs(lines) do
    lines[i] = spaces..line..'\n'
  end
  return table.concat(lines)
end

--- Returns a human-friendly representation of the given value.
--- This representation may not be valid Lua.
---
--- @param x any
--- @return string
function common.repr(x)
  if type(x) == "table" then
    local result = {}
    for k, v in pairs(x) do
      k = tostring(k)
      table.insert(result, common.indent(k.." = "..common.repr(v)..", \n", 2))
    end
    return "{\n"..table.concat(result).."}"
  elseif type(x) == "string" then
    return ("%q"):format(x)
  else
    return tostring(x)
  end
end

local floor, ceil = math.floor, math.ceil

--- Rounds the given number towards zero.
---
--- @param x number
--- @return number
function common.round(x)
  if x >= 0 then return floor(x + 0.5)
  else return ceil(x - 0.5) end
end

--- Linearly interpolates between the two values.
---
--- @param a number
--- @param b number
--- @param t number
--- @return number
function common.lerp(a, b, t)
  -- This is an "imprecise" method but hopefully it'll give LuaJIT a chance
  -- to optimize this into a fused multiply-add.
  return a + t * (b - a)
end

local min, max = math.min, math.max

--- Clamps x between a and b. a is the lower bound, and b is the upper bound.
--- Note that using a as the upper bound or b as the lower bound will result in
--- undefined behavior.
---
--- @param x number
--- @param a number
--- @param b number
--- @return number
function common.clamp(x, a, b)
  return max(min(x, b), a)
end

local pi = math.pi

--- Converts degrees to radians.
---
--- @param deg number
--- @return number
function common.degToRad(deg)
  return deg / 180 * pi
end

--- Converts radians to degrees.
---
--- @param rad number
--- @return number
function common.radToDeg(rad)
  return rad / pi * 180
end

-- Commonly used colors.

--- @type Color
common.white = { rgba(255, 255, 255) }
--- @type Color
common.black = { rgba(0, 0, 0) }
--- @type Color
common.transparent = { rgba(0, 0, 0, 0) }

-- Helper for common.hex, extends a single-character string to a
-- double-character string.
local function hexExtend(hex)
  if #hex == 1 then return hex..hex
  else return hex end
end

--- Converts an RGB hex color to normalized 0..1 RGBA values.
---
--- @param color string
--- @return number r
--- @return number g
--- @return number b
--- @return number a
function common.hex(color)
  if color:sub(1, 1) == '#' then
    color = color:sub(2)
  end
  local r, g, b
  local a = 255

  local rs, gs, bs, as = color:match("^(%x%x?)(%x%x?)(%x%x?)(%x?%x?)$")
  assert(bs ~= nil, "invalid color")
  rs = hexExtend(rs)
  gs = hexExtend(gs)
  bs = hexExtend(bs)
  r = tonumber(rs, 16)
  g = tonumber(gs, 16)
  b = tonumber(bs, 16)
  if #as > 0 then
    as = hexExtend(as)
    a = tonumber(as, 16)
  end

  return r / 255, g / 255, b / 255, a / 255
end

--- Returns the approximate luminance of the given color.
---
--- @param r number
--- @param g number
--- @param b number
--- @return number
function common.luma(r, g, b)
  return 0.299 * r + 0.587 * g + 0.114 * b
end

--- Verifies that str is one of the values provided in the varargs.
--- If not, errors out with a message like "invalid enum value, expected ...".
---
--- @param str string  The enum value to verify.
--- @vararg string     List of valid enum values.
function common.enum(str, ...)
  for i = 1, select('#', ...) do
    if str == select(i, ...) then
      return
    end
  end
  error(("invalid enum value %q, expected one of: %s")
    :format(str, table.concat({...}, " | ")))
end

return common
