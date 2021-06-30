-- Game state handling.

local Object = require "object"

---

--- @class State: Object
local State = Object:inherit()

-- Initializes a state's fields.
function State:init()
  self._nextState = nil
end

-- Sets what the next state should be.
function State:set(nextState)
  -- this field is read by the game loop to determine whether a state change
  -- should be done
  self._nextState = nextState
end

---
-- State interface
---
-- These functions can be implemented by states inheriting from the base
-- State object.

-- Called a constant amount of times per second.
function State:update() end

-- Called as fast as possible. The parameter is how much between the current
-- and next update rendering lands, and should be used for interpolating
-- drawing parameters when rendering.
function State:draw(alpha) end

return State
