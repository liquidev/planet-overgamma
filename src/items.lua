-- Item storage-related things.
--
-- Item amounts are represented as fixed-point numbers with one _decimal_ place,
-- so an amount of 1 is 0.1 of an item, and 10 is exactly 1 of an item.

local lmath = love.math

---

local items = {}

-- Returns an item stack with the given item ID and amount of items.
-- By default, amount = 10.
function items.stack(id, amount)
  return { id = id, amount = amount or 10 }
end

-- Returns an item drop with the given ID, min/max amounts, and chance of
-- dropping.
-- By default, min = 10, max = min, chance = 1.0.
function items.drop(id, min, max, chance)
  min = min or 10
  max = max or min
  chance = chance or 1.0
  return { id = id, min = min, max = max, chance = chance }
end

-- Draws a stack from the drop.
local function drawStack(drop)
  return items.stack(drop.id, lmath.random(drop.min, drop.max))
end

-- Draws an item from a single drop.
local function drawSingleItem(drop, index)
  if index then
    return nil
  end
  if lmath.random() < drop.chance then
    return 1, drawStack(drop)
  else
    return nil
  end
end

-- Draws items from a drop pool.
local function drawMultipleItems(pool, index)
  while true do
    if index > #pool then
      return nil
    end
    local drop = pool[index + 1]
    if lmath.random() < drop.chance then
      return index + 1, drawStack(drop)
    end
    index = index + 1
  end
end

-- An iterator that draws item amounts from the provided drops table.
-- The drops table can be a table of items.drop, or a single items.drop.
function items.draw(drops)
  if #drops == 0 then
    return drawSingleItem, drops
  else
    return drawMultipleItems, drops, 0
  end
end

return items
