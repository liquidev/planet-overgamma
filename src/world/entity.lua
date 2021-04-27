-- Base entity class.

local Object = require "object"

---

local Entity = Object:inherit()

-- Marks the entity for deletion.
function Entity:drop()
  self._doDrop = true
end

-- Update hook for the entity, nop by default.
-- This runs at a constant rate and should be where controls are handled.
function Entity:update() end

-- Draw hook for the entity, nop by default.
function Entity:draw(alpha) end


return Entity
