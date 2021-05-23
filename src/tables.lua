-- Table utilities. Mirrors vanilla Lua's `table` library.

local tables = {}

for k, v in pairs(table) do
  tables[k] = v
end

-- Fills a table with `len` `element`s. This doesn't clear anything past
-- `len` elements.
function tables.fill(t, len, element)
  for i = 1, len do
    t[i] = element
  end
  return t
end

-- Appends pairs from all arguments (tables) to `out` and returns `out`.
-- Pairs occuring in later arguments override pairs coming from earlier
-- arguments.
function tables.merge(out, ...)
  for _, table in ipairs {...} do
    for key, value in pairs(table) do
      out[key] = value
    end
  end
  return out
end

-- Recursively merges the two tables together.
-- The following rules are executed per key/value pair in `b`:
--  · if the value in `a` is a table and the value in `b` is a table,
--    the two tables are merged using this function
--  · otherwise, the value in `a` is overwritten with the value in `b`
function tables.mergeRec(a, b)
  for key, value in pairs(b) do
    if type(a[key]) == "table" and type(value) == "table" then
      tables.mergeRec(a[key], value)
    else
      a[key] = value
    end
  end
end

-- Performs an in-place copy of the array part of src into dest, and
-- returns dest.
-- dest defaults to a new, empty table ({}).
function tables.icopy(src, dest)
  dest = dest or {}
  for i = 1, #src do
    dest[i] = src[i]
  end
  return dest
end

-- In-place map operation. Passes each element in the table through the function
-- and replaces the element with the result of that function.
-- This function only operates on the array part of the table.
-- Returns the modified table.
function tables.imap(t, func)
  for i = 1, #t do
    t[i] = func(t[i])
  end
  return t
end

return tables
