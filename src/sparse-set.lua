-- Simple implementation of a sparse set.

local Object = require "object"

---

local SparseSet = Object:inherit()

function SparseSet:init()
  self.data = {}
  self.sparseToDense = {}
  self.denseToSparse = {}
  self.freedIDs = {}
  self.nextID = 1
end

local function getFreeIDs(set)
  local sparseID
  if #set.freedIDs > 0 then
    sparseID = table.remove(set.freedIDs)
  else
    sparseID = set.nextID
    set.nextID = set.nextID + 1
  end

  return sparseID, #set.denseToSparse + 1
end

-- Inserts an element into the sparse set and returns its ID.
function SparseSet:insert(element)
  local id, denseID = getFreeIDs(self)
  self.data[id] = element
  self.sparseToDense[id] = denseID
  self.denseToSparse[denseID] = id
  return id
end

-- Returns the element with the given ID.
function SparseSet:get(id)
  return self.data[id]
end

-- Removes the element with the given ID.
-- Returns the removed element.
function SparseSet:remove(id)
  local denseID = self.sparseToDense[id]
  local data = self.data[id]
  self.data[id] = nil
  self.sparseToDense[id] = nil
  self.denseToSparse[denseID] = self.denseToSparse[#self.denseToSparse]
  self.denseToSparse[#self.denseToSparse] = nil
  table.insert(self.freedIDs, id)
  return data
end

-- Returns an iterator over IDs of elements.
-- As a side effect of how Lua iterators work, the first variable the iterator
-- yields is the index in the dense part of the sparse set and should generally
-- be ignored.
function SparseSet:ipairs()
  return ipairs(self.dense)
end

return SparseSet
