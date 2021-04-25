-- General-purpose name-numeric ID registry.
-- Automatically creates keys on demand, and reuses existing entries.
--
-- Using registry-provided IDs instead of strings may be faster in certain
-- cases. IDs start at 1 and increase monotonically. If all registry IDs
-- correspond to keys in some table, Lua will use the "array part" of the table,
-- resulting in better indexing performance, as the key does not need to be
-- hashed.

local Registry = {}
Registry.__name = "Registry"

-- Creates and initializes a new registry.
function Registry:new()
  local r = setmetatable({
    _ids = {},
    _keys = {},
    _nextID = 1,
  }, self)
  return r
end

-- Errors out, because registry indices cannot be overridden.
function Registry.__newindex()
  error("registry indices cannot be overridden")
end

-- Returns a unique ID for the given key.
-- A valid key is any string that doesn't begin with an underscore `_`,
-- as single-underscored keys are reserved for storing internal data.
-- This isn't checked for performance reasons, but do bear in mind that certain
-- keys beginning with `_` may not return valid IDs.
function Registry:__index(key)
  if self._ids[key] == nil then
    local id = self._nextID
    self._ids[key] = id
    self._keys[id] = key
    self._nextID = id + 1
    return id
  end
  return self._ids[key]
end

-- The following functions must be called using `Registry.someFn(reg, ...)`
-- syntax, so as not to collide with valid registry keys.

-- Returns whether the given registry has the given key.
function Registry.hasKey(reg, key)
  return reg._ids[key] ~= nil
end

-- Returns the key for the unique ID.
function Registry.key(reg, id)
  return reg._keys[id]
end

return Registry
