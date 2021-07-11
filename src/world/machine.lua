-- Framework for implementing machines.

local graphics = love.graphics

local game = require "game"
local Object = require "object"

---

--- @class Machine: Object
local Machine = Object:inherit()

--- @class Node: Object
local Node = Object:inherit()

--- The name of a machine.
--- This should be overridden by each individual machine.
--- Note that machines added using the mod API have the namespace prefix added
--- automatically, so this name should not be namespaced manually.
---
--- @type string
Machine.__name = "machine"

--- The hardness of a machine. Can be changed if needed.
---
--- @type number
Machine.hardness = 1.3

--- Initializes a new machine.
---
--- @param world World
--- @param position Vec
function Machine:init(world, position)
  self.world = world
  self.position = position
  self.sprites = game.machines[self.__name].sprites
  self.spriteIndex = 1
  self:setup()
end

-- Renders the machine. If overridden, the super-object's draw must call this
-- for the chassis to render.
function Machine:draw(alpha)
  local sprite = self.sprites[self.spriteIndex]
  graphics.draw(sprite, 0, 0)
end

-- Setup endpoint. Called when the machine object has just been created.
function Machine:setup() end

return Machine

