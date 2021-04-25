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

return tables
