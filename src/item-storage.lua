-- Item storage, with support for several queries, putting, and taking out
-- items.

local Object = require "object"

---

local ItemStorage = Object:inherit()

-- Initializes a new item storage with the given limits (table).
-- The table must have the following structure:
-- {
--   -- Specifies how many items the storage can hold in total.
--   size: number = math.huge,
--   -- Specifies how many item stacks (different IDs) the storage can hold.
--   stacks: number = math.huge,
-- }
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

-- Returns the amount of storage that is occupied.
function ItemStorage:occupied()
  return self._occupied
end

-- Returns the amount of storage that is still free.
function ItemStorage:free()
  return self.size - self._occupied
end

-- Returns the number of item stacks in the storage.
function ItemStorage:stackCount()
  return self._stackCount
end

-- Retrieves a stack from the storage, creating it if it doesn't exist.
-- If the stack count exceeds the maximum stack count specified during storage
-- creation, returns nil.
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

-- Attempts to put an item or item stack into the storage. Returns the actual
-- amount of items added.
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
    self.onChanged(id, stack.amount, previousAmount)
    return amount
  end
  return 0
end

-- Removes the stack for the given item ID if it's empty.
local function collectStack(storage, id)
  if storage.stacks[id].amount <= 0 then
    storage.stacks[id] = nil
  end
end

-- Attempts to take the provided amount of items out of the item storage.
-- Returns the actual amount of items that were taken out.
function ItemStorage:take(id, amount)
  local stack = self.stacks[id]
  if stack == nil then return 0 end
  amount = math.min(amount, stack.amount)
  local previousAmount = stack.amount
  stack.amount = stack.amount - amount
  self._occupied = self._occupied - amount
  if amount > 0 then
    self.onChanged(id, stack.amount, previousAmount)
  end
  collectStack(self, id)
  return amount
end

-- Gets the amount of the given item stored in the storage.
function ItemStorage:get(id)
  if self.stacks[id] then
    return self.stacks[id].amount
  end
  return 0
end

return ItemStorage

