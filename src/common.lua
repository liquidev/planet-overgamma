-- Utility functions that are used commonly.

local rgba = love.math.colorFromBytes

---

local common = {}

-- Does nothing.
function common.noop() end

-- Better version of pcall that returns an error with a stack traceback.
--
-- Calls fn in "protected mode" - instead of propagating errors that occur
-- inside fn up the stack, it catches them. If no error occurs, returns true
-- alongside all results the original function returned.
-- If an error occured, returns false alongside an error message string,
-- containing the original error converted to a string, along with a
-- stack traceback.
function common.try(fn, ...)
  local args = {...}
  return xpcall(function ()
    return fn(unpack(args))
  end, function (error)
    return debug.traceback(tostring(error))
  end)
end

-- Prepends `level` amount of spaces to each line in the given string.
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

-- Returns a human-friendly representation of the given value.
-- This representation may not be valid Lua.
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

-- Rounds the given number towards zero.
local floor, ceil = math.floor, math.ceil
function common.round(x)
  if x >= 0 then return floor(x + 0.5)
  else return ceil(x - 0.5) end
end

-- Linearly interpolates between the two values.
function common.lerp(a, b, t)
  -- This is an "imprecise" method but hopefully it'll give LuaJIT a chance
  -- to optimize this into a fused multiply-add.
  return a + t * (b - a)
end

-- Clamps x between a and b. a is the lower bound, and b is the upper bound.
-- Note that using a as the upper bound or b as the lower bound will result in
-- undefined behavior.
local min, max = math.min, math.max
function common.clamp(x, a, b)
  return max(min(x, b), a)
end

local pi = math.pi

-- Converts degrees to radians.
function common.degToRad(deg)
  return deg / 180 * pi
end

-- Converts radians to degrees.
function common.radToDeg(rad)
  return rad / pi * 180
end

-- Commonly used colors.
common.white = { rgba(255, 255, 255) }
common.black = { rgba(0, 0, 0) }
common.transparent = { rgba(0, 0, 0, 0) }

-- Helper for common.hex, extends a single-character string to a
-- double-character string.
local function hexExtend(hex)
  if #hex == 1 then return hex..hex
  else return hex end
end

-- Converts an RGB hex color to normalized 0..1 RGBA values.
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

return common
