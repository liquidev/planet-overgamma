-- Framework for implementing machines.

local game = require "game"
local Object = require "object"

---

local Machine = Object:inherit()

-- The name of a machine.
-- This should be overridden by each individual machine.
-- Note that machines added using the mod API have the namespace prefix added
-- automatically, so this name should not be namespaced manually.
Machine.__name = "machine"

-- Initializes a new machine.
function Machine:init(world, position)
  self.world = world
  self.position = position
  self.sprites = game.machines[self.__name].sprites
  self.spriteIndex = 1
  self:setup()
end

-- Renders the machine. If overridden, the super-object's draw must call this
-- for the chassis to render.
function Machine:draw() end

-- Setup endpoint. Called when the machine object has just been created.
function Machine:setup() end

return Machine

