-- Item storage, with support for several queries, putting, and taking out
-- items.

local items = require "items"
local Object = require "object"

---

--- @class ItemStorage: Object
local ItemStorage = Object:inherit()

--- @alias StorageLimits { size: number, stacks: number }

--- Initializes a new item storage with the given limits (table).
--- @param limits StorageLimits
function ItemStorage:init(limits)
  limits = limits or {}
  self.size = limits.size or math.huge
  self.maxStacks = limits.stacks or math.huge

  self.stacks = {}
  self._occupied = 0
  self._stackCount = 0

  -- Called when items are added or removed from the storage.
  --
  -- id is the item ID.
  -- amount is the amount of items after the change.
  -- previousAmount is the amount of items before the change.
  function self.onChanged(id, amount, previousAmount) end
end

--- Returns the amount of storage that is occupied.
--- @return number
function ItemStorage:occupied()
  return self._occupied
end

--- Returns the amount of storage that is still free.
--- @return number
function ItemStorage:free()
  return self.size - self._occupied
end

--- Returns the number of item stacks in the storage.
--- @return number
function ItemStorage:stackCount()
  return self._stackCount
end

--- Retrieves a stack from the storage, creating it if it doesn't exist.
--- If the stack count exceeds the maximum stack count specified during storage
--- creation, returns nil.
---
--- @param storage ItemStorage
--- @param id number
--- @return table | nil
local function getStack(storage, id)
  if storage.stacks[id] == nil then
    if storage._stackCount >= storage.maxStacks then
      return nil
    end
    storage.stacks[id] = { id = id, amount = 0 }
    storage._stackCount = storage._stackCount + 1
  end
  return storage.stacks[id]
end

--- Attempts to put an item or item stack into the storage. Returns the actual
--- amount of items added.
---
--- @param idOrStack number | table
--- @param amount number | nil
--- @return number
function ItemStorage:put(idOrStack, amount)
  local id
  if type(idOrStack) == "table" then
    id, amount = idOrStack.id, idOrStack.amount
  else
    id = idOrStack
  end
  amount = math.min(amount, self:free())
  local stack = getStack(self, id)
  if stack ~= nil then
    local previousAmount = stack.amount
    stack.amount = stack.amount + amount
    self._occupied = self._occupied + amount
    if amount > 0 then
      self.onChanged(id, stack.amount, previousAmount)
      self._sorted = nil
    end
    return amount
  end
  return 0
end

--- Removes the stack for the given item ID if it's empty.
---
--- @param storage ItemStorage
--- @param id number
local function collectStack(storage, id)
  if storage.stacks[id].amount <= 0 then
    storage.stacks[id] = nil
  end
end

--- Attempts to take the provided amount of items out of the item storage.
--- Returns the actual amount of items that were taken out.
---
--- @param id number
--- @param amount number
--- @return number
function ItemStorage:take(id, amount)
  local stack = self.stacks[id]
  if stack == nil then return 0 end
  amount = math.min(amount, stack.amount)
  local previousAmount = stack.amount
  stack.amount = stack.amount - amount
  self._occupied = self._occupied - amount
  if amount > 0 then
    self.onChanged(id, stack.amount, previousAmount)
    self._sorted = nil
  end
  collectStack(self, id)
  return amount
end

--- Gets the amount of the given item stored in the storage.
---
--- @param id number
--- @return number
function ItemStorage:get(id)
  if self.stacks[id] then
    return self.stacks[id].amount
  end
  return 0
end

local stackCmp = {}
stackCmp.amount = {}
stackCmp.name = {}

function stackCmp.amount.descending(a, b)
  if a.amount == b.amount then return a.id < b.id
  else return a.amount > b.amount end
end

function stackCmp.amount.ascending(a, b)
  if a.amount == b.amount then return a.id < b.id
  else return a.amount < b.amount end
end

function stackCmp.name.descending(a, b)
  local nameA = items.tr(a.id)
  local nameB = items.tr(b.id)
  if nameA == nameB then return a.id < b.id
  else return items.tr(a.id) > items.tr(b.id) end
end

function stackCmp.name.ascending(a, b)
  local nameA = items.tr(a.id)
  local nameB = items.tr(b.id)
  if nameA == nameB then return a.id < b.id
  else return items.tr(a.id) < items.tr(b.id) end
end

--- Returns a sorted table of all items in the storage.
---
--- @param by '"amount"' | '"name"'
--- @param order '"ascending"' | '"descending"'
function ItemStorage:sorted(by, order)
  if self._sorted == nil then
    self._sorted = {}
    for _, stack in pairs(self.stacks) do
      table.insert(self._sorted, stack)
    end
    -- Using an unstable sort here is fine, as there cannot be two different
    -- items with the same ID. All sorting functions fall back to sorting by ID
    -- if the first criterion fails (two items in the criterion are the same).
    table.sort(self._sorted, stackCmp[by][order])
  end
  return self._sorted
end

return ItemStorage

