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
function common.round(x)
  if x >= 0 then return math.floor(x + 0.5)
  else return math.ceil(x - 0.5) end
end

-- Linearly interpolates between the two values.
function common.lerp(a, b, t)
  -- This is an "imprecise" method but hopefully it'll give LuaJIT a chance
  -- to optimize this into a fused multiply-add.
  return a + t * (b - a)
end

-- Converts degrees to radians.
function common.degToRad(deg)
  return deg / 180 * math.pi
end

-- Converts radians to degrees.
function common.radToDeg(rad)
  return rad / math.pi * 180
end

-- Commonly used colors.
common.white = { rgba(255, 255, 255) }
common.black = { rgba(0, 0, 0) }
common.transparent = { rgba(0, 0, 0, 0) }

return common
