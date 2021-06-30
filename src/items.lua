-- Item storage-related things.
--
-- Item amounts are represented as fixed-point numbers with one _decimal_ place,
-- so an amount of 1 is 0.1 of an item, and 10 is exactly 1 of an item.

local lmath = love.math

local game = require "game"
local Registry = require "registry"
local tr = require("i18n").tr

---

local items = {}

--- @alias ItemStack { id: number, amount: number }

--- Returns an item stack with the given item ID and amount of items.
--- By default, amount = 10.
---
--- @param id number
--- @param amount number | nil
--- @return ItemStack
function items.stack(id, amount)
  assert(type(id) == "number", "item ID must be numeric")
  return { id = id, amount = amount or 10 }
end

--- @alias ItemDrop { id: number, min: number, max: number, chance: number }

--- Returns an item drop with the given ID, min/max amounts, and chance of
--- dropping.
--- By default, min = 10, max = min, chance = 1.0.
---
--- @param id number
--- @param min number | nil
--- @param max number | nil
--- @param chance number | nil
--- @return ItemDrop
function items.drop(id, min, max, chance)
  min = min or 10
  max = max or min
  chance = chance or 1.0
  return { id = id, min = min, max = max, chance = chance }
end

--- Draws a stack from the drop.
local function drawStack(drop)
  return items.stack(drop.id, lmath.random(drop.min, drop.max))
end

--- Draws an item from a single drop.
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

--- Draws items from a drop pool.
local function drawMultipleItems(pool, index)
  while true do
    if index >= #pool then
      return nil
    end
    local drop = pool[index + 1]
    if lmath.random() < drop.chance then
      return index + 1, drawStack(drop)
    end
    index = index + 1
  end
end

--- An iterator that draws item amounts from the provided drops table.
--- The drops table can be a table of items.drop, or a single items.drop.
---
--- @param drops ItemDrop[]
--- @return function iterator
--- @return ItemDrop[] drops
--- @return number | nil index
function items.draw(drops)
  if #drops == 0 then
    return drawSingleItem, drops
  else
    return drawMultipleItems, drops, 0
  end
end

--- Translates the item ID to a string.
---
--- @param id number
--- @return string
function items.tr(id)
  return tr("item/"..Registry.key(game.itemIDs, id))
end

--- Formats an item amount by adding a decimal separator.
---
--- @param amount number
--- @return string
function items.quantity(amount)
  return ("%.1f"):format(amount / 10)
end

local function shortQuantity(x)
  x = math.floor(x / 0.1) * 0.1
  if x % 1 == 0 then return tostring(x)
  else return ("%.1f"):format(math.floor(x / 0.1) * 0.1) end
end

local quantityUnits = {
  -- For performance's sake, let's assume no formatted amount will be greater
  -- than 1T.
  { 1000000000000, "T" },
  { 1000000000, "G" },
  { 1000000, "M" },
  { 1000, "k" },
}

--- Formats an item amount to a short form, with a unit dependent on how large
--- the amount is.
---
--- @param amount number
--- @return string
function items.unitQuantity(amount)
  amount = amount / 10
  for _, unitData in ipairs(quantityUnits) do
    local minAmount, unit = unpack(unitData)
    if amount >= minAmount then
      return shortQuantity(amount / minAmount)..unit
    end
  end
  return shortQuantity(amount)
end

--- Converts an item stack to a string.
function items.stackToString(stack)
  return items.quantity(stack.amount).." × "..items.tr(stack.id)
end


return items
