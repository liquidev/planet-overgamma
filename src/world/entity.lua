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

-- Update hook for the entity, done before any physics updates.
-- Code that requires the player position to be sensible has to run here to
-- prevent jank with passing the world seam.
function Entity:prePhysicsUpdate() end

-- Draw hook for the entity, nop by default.
function Entity:draw(alpha) end


return Entity
