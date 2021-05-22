-- Table utilities. Mirrors vanilla Lua's `table` library.

local tables = {}

for k, v in pairs(table) do
  tables[k] = v
end

-- Fills a table with `len` `element`s. This doesn't clear anything past
-- `len` elements.
function tables.fill(table, len, element)
  for i = 1, len do
    table[i] = element
  end
  return table
end

-- Appends pairs from all arguments (tables) to `out` and returns `out`.
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

return tables
