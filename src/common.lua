-- Utility functions that are used commonly.

local common = {}

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

return common
