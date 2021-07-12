-- Game world. This handles all blocks, entities, and body physics.

local bit = require "bit"

local band, bor = bit.band, bit.bor
local shl = bit.lshift

local Object = require "object"
local SparseSet = require "sparse-set"
local tables = require "tables"
local Vec = require "vec"

---

--
-- Chunk
--

--- @class Chunk: Object
local Chunk = Object:inherit()

--- The amount of tiles a chunk occupies.
--- @type number
Chunk.size = 8
--- The size of a single tile in units.
--- @type number
Chunk.tileSize = 8
--- The size of a chunk in units.
--- @type number
Chunk.unitSize = Chunk.size * Chunk.tileSize

--- Initializes a new chunk.
--- All blocks in the chunk will be 0, ie. air.
function Chunk:init()
  local tileCount = Chunk.size ^ 2
  self.blocks = tables.fill({}, tileCount, 0)
  self.ores = tables.fill({}, tileCount, 0)
  self.oreAmounts = tables.fill({}, tileCount, 0)
  -- The machines table simply stores machine IDs that are then indexed in the
  -- world itself. This is used to enable better culling and serialization
  -- support: the less pointers you have in your data, the easier it is to
  -- serialize later.
  -- A machine with ID 0 does not exist, as all IDs count up from 1 - ID 0 is
  -- used as "no machine".
  self.machines = tables.fill({}, tileCount, 0)
  -- This table is a set of machine IDs present in the given chunk.
  -- This is used when rendering.
  self.machinesPresent = {}
end

local function indexInChunk(vec)
  local x, y = vec:xy()
  return 1 + x + y * Chunk.size
end

--- Gets the block ID at the given position. The position must be in
--- the chunk's boundaries, otherwise behavior is undefined for
--- better performance.
---
--- @param position Vec
--- @return number
function Chunk:block(position)
  return self.blocks[indexInChunk(position)]
end

--- Sets the block ID at the given position. Again, the position must be in
--- the chunk's boundaries, otherwise behavior is undefined.
--- Returns the old block.
---
--- @param position Vec
--- @param newBlock number
--- @return number oldID
function Chunk:setBlock(position, newBlock)
  local i = indexInChunk(position)
  local old = self.blocks[i]
  self.blocks[i] = newBlock
  self.dirty = true
  return old
end

--- Returns the ID and amount of ore at the given position.
--- Out of bounds access is undefined behavior.
---
--- @param position Vec
--- @return number oreID
--- @return number amount
function Chunk:ore(position)
  local i = indexInChunk(position)
  return self.ores[i], self.oreAmounts[i]
end

--- Sets the ore ID and amount at the given position.
--- Out of bounds access is undefined behavior.
--- Returns the old ID and amount.
---
--- @param position Vec
--- @param id number
--- @param amount number
--- @return number oldID
--- @return number oldAmount
function Chunk:setOre(position, id, amount)
  local i = indexInChunk(position)
  local oldID, oldAmount = self.ores[i], self.oreAmounts[i]
  if amount == 0 then id = 0 end
  self.ores[i], self.oreAmounts[i] = id, amount
  self.dirty = true
  return oldID, oldAmount
end

--- Adds the given amount of ore with the given ID to the given position.
--- If limit is not nil, it is used to limit how much ore can be present at that
--- tile. By default, the limit is math.huge.
---
--- @param position Vec
--- @param id number
--- @param amount number
--- @param limit number | nil
function Chunk:addOre(position, id, amount, limit)
  limit = limit or math.huge
  local i = indexInChunk(position)
  local oreID = self.ores[i]
  if oreID == 0 then
    self.ores[i] = id
  elseif oreID ~= id then
    return
  end
  self.oreAmounts[i] = math.min(self.oreAmounts[i] + amount, limit)
  self.dirty = true
end

--- Tries to remove the given amount of ore from the tile at the given position.
--- Returns the ID and actual amount that could be retrieved.
--- If there is no ore left, sets the ID at the given position to no ore (0).
--- Out of bounds access is undefined.
---
--- @param position Vec
--- @param amount number
--- @return number id
--- @return number amount
function Chunk:removeOre(position, amount)
  local i = indexInChunk(position)
  local id, amountInOre = self.ores[i], self.oreAmounts[i]
  amount = math.min(amount, amountInOre)
  self.oreAmounts[i] = self.oreAmounts[i] - amount
  if self.oreAmounts[i] == 0 then
    self.ores[i] = 0
  end
  self.dirty = true
  return id, amount
end

--- Returns the ID of the machine at the given position.
--- Out of bounds access is undefined.
---
--- @param position Vec
--- @return number
function Chunk:machineID(position)
  return self.machines[indexInChunk(position)]
end

--- Sets the ID of the machine at the given position.
--- Returns the ID of the old machine.
--- Out of bounds access is undefined.
---
--- @param position Vec
--- @param id number
--- @return number oldID
function Chunk:setMachineID(position, id)
  -- Placing a machine in a chunk does not mark the chunk as dirty, as machines
  -- are not rendered by the chunk renderer directly.
  local i = indexInChunk(position)
  local old = self.machines[i]
  self.machines[i] = id
  self.machinesPresent[old] = nil
  if id ~= 0 then
    self.machinesPresent[id] = true
  end
  return old
end


--
-- World
--

--- @class World: Object
local World = Object:inherit()
World.Chunk = Chunk

require("world.physics")(World)
require("world.interaction")(World)

--- The ID of air.
World.air = 0
--- The ID of no ore.
World.noOre = 0

--- Initializes a new world with the given width (in tiles).
---
--- @param width number  Width, must be divisible by `Chunk.size`.
--- @param gravity Vec
function World:init(width, gravity)
  assert(width % Chunk.size == 0,
         "world width must be divisible by "..Chunk.size)

  -- size
  self.width = width
  self.unitWidth = width * Chunk.tileSize

  self.chunks = {}
    -- ↑ don't index this directly unless you know what you're doing

  -- entities
  self.entities = {}
  self.spawnQueue = {}

  -- machines
  self.machines = SparseSet:new()

  self:initPhysics(gravity)
end

--- Packs a chunk position vector into a number.
---
--- @param position Vec
--- @return integer
local function packChunkPosition(position)
  -- This limits chunk coordinates to 16-bit signed integers, but honestly
  -- I don't think anyone will ever try to generate a world that's 65536 chunks
  -- (524288 blocks) in size, as walking across that would take you about
  -- 30 days non-stop.
  return bor(shl(band(position.x, 0xFFFF), 16), band(position.y, 0xFFFF))
end

--- Converts the provided vector to a chunk position.
---
--- @param v Vec
--- @return Vec
function World.chunkPosition(v)
  return Vec(math.floor(v.x / Chunk.size), math.floor(v.y / Chunk.size))
end

--- Converts the provided vector to a tile position in a chunk.
---
--- @param v Vec
--- @return Vec
function World.positionInChunk(v)
  return Vec(math.floor(v.x % Chunk.size), math.floor(v.y % Chunk.size))
end

--- Converts the provided tile position to a unit position with the specified
--- alignment relative to a tile.
World.unitPosition = {}

--- @param position Vec
--- @return Vec
function World.unitPosition.topLeft(position)
  return position * Chunk.tileSize
end

--- @param position Vec
--- @return Vec
function World.unitPosition.center(position)
  local tileSize = Vec(Chunk.tileSize, Chunk.tileSize)
  return position * tileSize + tileSize / 2
end

--- Wraps the given block position around the world seam.
---
--- @param position Vec
--- @return Vec
function World:wrapPosition(position)
  return Vec(position.x % self.width, position.y)
end

local wrapPosition = World.wrapPosition

--- Wraps the given chunk position around the world seam.
---
--- @param position Vec
--- @return Vec
function World:wrapChunkPosition(position)
  local widthInChunks = self.width / Chunk.size
  return Vec(math.floor(position.x % widthInChunks), math.floor(position.y))
end

local wrapChunkPosition = World.wrapChunkPosition

--- Returns the chunk with the given position. If the chunk doesn't exist,
--- creates one.
---
--- @param position Vec
--- @return Chunk
function World:ensureChunk(position)
  position = wrapChunkPosition(self, position)
  local packed = packChunkPosition(position)
  if self.chunks[packed] == nil then
    self.chunks[packed] = Chunk:new()
  end
  return self.chunks[packed]
end

--- Returns the chunk with the given position. If the chunk doesn't exist,
--- returns nil.
---
--- @param position Vec
--- @return Chunk | nil
function World:chunk(position)
  position = wrapChunkPosition(self, position)
  local packed = packChunkPosition(position)
  return self.chunks[packed]
end

--- Marks the chunk at the given position as dirty, which causes it to rebuild
--- its sprite batch when it is about to be drawn.
---
--- @param chunkPosition Vec
function World:markDirty(chunkPosition)
  local chunk = self:chunk(chunkPosition)
  if chunk ~= nil then
    chunk.dirty = true
  end
end

local chunkPosition = World.chunkPosition
local positionInChunk = World.positionInChunk

--- Marks all chunks adjacent to the given position dirty.
---
--- @param position Vec
function World:markDirtyChunks(position)
  local chp = chunkPosition(position)
  local pic = positionInChunk(position)
  self:markDirty(chp)
  if pic.x == 0 then
    self:markDirty(chp + Vec(-1, 0))
  end
  if pic.x == Chunk.size - 1 then
    self:markDirty(chp + Vec(1, 0))
  end
  if pic.y == 0 then
    self:markDirty(chp + Vec(0, -1))
  end
  if pic.y == Chunk.size - 1 then
    self:markDirty(chp + Vec(0, 1))
  end
end

--- Gets the block at the given position.
--- If the position lands outside of any chunks, `World.air` (0) is returned.
---
--- @param position Vec
--- @return number
function World:block(position)
  position = wrapPosition(self, position)

  local chunk = self:chunk(chunkPosition(position))
  if chunk ~= nil then
    return chunk:block(positionInChunk(position))
  else
    return World.air
  end
end

--- Sets the block at the given position, creating a new chunk if necessary.
--- Returns the old block.
---
--- @param position Vec
--- @param newBlock number
--- @return number
function World:setBlock(position, newBlock)
  position = wrapPosition(self, position)

  local chunk = self:ensureChunk(chunkPosition(position))
  self:markDirtyChunks(position)
  return chunk:setBlock(positionInChunk(position), newBlock)
end

--- Returns the ID and amount of ore at the given position.
--- If the position lands outside of any chunks, `World.noOre, 0` is returned.
---
--- @param position Vec
--- @return number oreID
--- @return number oreAmount
function World:ore(position)
  position = wrapPosition(self, position)

  local chunk = self:chunk(chunkPosition(position))
  if chunk ~= nil then
    return chunk:ore(positionInChunk(position))
  else
    return World.noOre, 0
  end
end

local function cannotHaveOre(chunk, position)
  return chunk == nil or chunk:block(positionInChunk(position)) == World.air
end

--- Sets the ID and amount of ore at the given position.
--- Returns the old ID and amount of ore.
--- If the block at the given position is air, no ore is set and
--- (World.noOre, 0) is returned.
---
--- @param position Vec
--- @param id number
--- @param amount number
--- @return number oldOreID
--- @return number oldAmount
function World:setOre(position, id, amount)
  position = wrapPosition(self, position)
  local chunk = self:chunk(chunkPosition(position))
  if cannotHaveOre(chunk, position) then
    return World.noOre, 0
  end

  return chunk:ore(positionInChunk(position))
end

--- Adds an amount of ore to the tile at the given position.
--- Does not override ores with an ID different than the one provided.
--- If limit is specified, the amount of ore will be clamped to that limit.
---
--- @param position Vec
--- @param id number
--- @param amount number
--- @param limit number
function World:addOre(position, id, amount, limit)
  position = wrapPosition(self, position)
  local chunk = self:chunk(chunkPosition(position))
  if cannotHaveOre(chunk, position) then
    return
  end

  return chunk:addOre(positionInChunk(position), id, amount, limit)
end

--- Tries to remove the given amount of ore from the tile at the given position.
--- Returns the ID of the ore, and the actual amount removed.
---
--- @param position Vec
--- @param amount number
--- @return number oreID
--- @return number amountRemoved
function World:removeOre(position, amount)
  position = wrapPosition(self, position)
  local chunk = self:chunk(chunkPosition(position))
  if cannotHaveOre(chunk, position) then
    return World.noOre, 0
  end

  return chunk:removeOre(positionInChunk(position), amount)
end

--- Returns the machine ID at the given position. Only use this if you know
--- what you're doing.
---
--- @unsafe
--- @param position Vec
--- @return number
function World:machineID(position)
  position = wrapPosition(self, position)
  local chunk = self:chunk(chunkPosition(position))
  if chunk ~= nil then
    return chunk:machineID(positionInChunk(position))
  end
  return 0
end

--- Returns the machine at the given position, or nil if there is no machine
--- there.
---
--- @param position Vec
--- @return Machine | nil
function World:machine(position)
  return self.machines:get(self:machineID(position))
end

--- Sets the machine at the given position. If machine is nil, removes the
--- machine at the given position.
--- Returns the old machine at the given position, or nil if there was no
--- machine in the first place.
---
--- @param position Vec
--- @param machine Machine
--- @return Machine | nil
function World:setMachine(position, machine)
  position = wrapPosition(self, position)

  local chunk = self:ensureChunk(chunkPosition(position))
  local newID = 0
  if machine ~= nil then
    newID = self.machines:insert(machine)
  end
  local oldID = chunk:setMachineID(positionInChunk(position), newID)
  local oldMachine = nil
  if oldID ~= 0 then
    oldMachine = self.machines:remove(oldID)
  end
  return oldMachine
end

--- Returns whether the tile at the given position is an empty (air) tile
--- unoccupied by any machines.
---
--- @param position Vec
--- @return boolean
function World:isEmpty(position)
  return
    self:block(position) == World.air and
    self:machineID(position) == 0
end

--- Returns the kind of tile at the given position.
---
--- Possible kinds include:
---  · "empty": an empty tile
---  · "block": a block with no ore
---  · "block+ore": a block with ore
---  · "machine": a machine
---
--- @param position Vec
--- @return string
function World:kind(position)
  position = wrapPosition(self, position)
  if self:block(position) ~= 0 then
    if self:ore(position) ~= 0 then return "block+ore"
    else return "block" end
  elseif self:machineID(position) ~= 0 then return "machine"
  else return "empty" end
end

--- Spawns the given entity into the world, returns the entity.
---
--- @param entity Entity`
function World:spawn(entity)
  table.insert(self.spawnQueue, entity)
  return entity
end

--- Ticks the world: updates all entities and spawns queued ones.
function World:update()
  for i, entity in ipairs(self.spawnQueue) do
    table.insert(self.entities, entity)
    self.spawnQueue[i] = nil
  end

  for _, entity in ipairs(self.entities) do
    entity:prePhysicsUpdate()
  end

  self:updatePhysics()

  local i = 1
  local count = #self.entities
  while i <= count do
    local entity = self.entities[i]
    entity:update()
    if entity._doDrop then
      self.entities[i] = self.entities[count]
      self.entities[count] = nil
      count = count - 1
    else
      i = i + 1
    end
  end
end

World.draw = require "world.renderer"

return World
