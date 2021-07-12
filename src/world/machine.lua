-- Framework for implementing machines.

local graphics = love.graphics

local common = require "common"
local game = require "game"
local Object = require "object"

---

--- @class Port: Object
local Port = Object:inherit()

--- @alias PortDirection '"in"' | '"out"'
--- @alias PortKind '"item"'

--- Initializes a new I/O port.
---
--- @param direction PortDirection  Whether the port is an input or output.
--- @param kind PortKind            What the port transmits or receives.
function Port:init(direction, kind)
  common.enum(direction, "in", "out")
  common.enum(kind, "item")
  self.direction = direction
  self.kind = kind
end

---

--- @class Machine: Object
local Machine = Object:inherit()

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

  self.ports = {}
    -- These tables are numeric and named mappings for I/O ports.
    -- Numeric indices are available for iterating over ports with ipairs,
    -- and string indices are available for accessing ports in update code.

  self:setup()
end

--- Initializes a new input port with the given name, transfer direction,
--- and kind.
--- Returns the port. The port is also accessible via the machine's `ports`
--- field.
---
--- @param name string
--- @param direction PortDirection
--- @param kind PortKind
--- @return Port
function Machine:addPort(name, direction, kind)
  assert(type(name) == "string", "the port name must be a string")

  local port = Port:new(direction, kind)
  table.insert(self.ports, port)
  self.ports[name] = port
  return port
end

--- Renders the machine. If overridden, the super-object's draw must call this
--- for the chassis to render.
function Machine:draw(alpha)
  local sprite = self.sprites[self.spriteIndex]
  graphics.draw(sprite, 0, 0)
end

--- Setup endpoint. Called when the machine object has just been created.
--- You should override this instead of `Machine:init()`.
function Machine:setup() end

return Machine

