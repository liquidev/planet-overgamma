-- Game world. This handles all blocks, entities, and body physics.

local bit = require "bit"

local band, bor = bit.band, bit.bor
local shl = bit.lshift

local Object = require "object"
local tables = require "tables"
local Vec = require "vec"

---

--
-- Chunk
--

local Chunk = Object:inherit()

-- The amount of tiles a chunk occupies.
Chunk.size = 8
-- The size of a single tile in units.
Chunk.tileSize = 8
-- The size of a chunk in units.
Chunk.unitSize = Chunk.size * Chunk.tileSize

-- Initializes a new chunk.
-- All blocks in the chunk will be 0, ie. air.
function Chunk:init()
  local tileCount = Chunk.size ^ 2
  self.blocks = tables.fill({}, tileCount, 0)
  self.ores = tables.fill({}, tileCount, 0)
  self.oreAmounts = tables.fill({}, tileCount, 0)
end

local function indexInChunk(vec)
  local x, y = vec:xy()
  return 1 + x + y * Chunk.size
end

-- Gets the block ID at the given position. The position must be in
-- the chunk's boundaries, otherwise behavior is undefined for
-- better performance.
function Chunk:block(position, newBlock)
  local i = indexInChunk(position)
  return self.blocks[i]
end

-- Sets the block ID at the given position. Again, the position must be in
-- the chunk's boundaries, otherwise behavior is undefined.
-- Returns the old block.
function Chunk:setBlock(position, newBlock)
  local i = indexInChunk(position)
  local old = self.blocks[i]
  self.blocks[i] = newBlock
  self.dirty = true
  return old
end

-- Returns the ID and amount of ore at the given position.
-- Out of bounds access is undefined behavior.
function Chunk:ore(position)
  local i = indexInChunk(position)
  return self.ores[i], self.oreAmounts[i]
end

-- Sets the ore ID and amount at the given position.
-- Out of bounds access is undefined behavior.
-- Returns the old ID and amount.
function Chunk:setOre(position, id, amount)
  local i = indexInChunk(position)
  local oldID, oldAmount = self.ores[i], self.oreAmounts[i]
  if amount == 0 then id = 0 end
  self.ores[i], self.oreAmounts[i] = id, amount
  self.dirty = true
  return oldID, oldAmount
end

-- Adds the given amount of ore with the given ID to the given position.
-- If limit is not nil, it is used to limit how much ore can be present at that
-- tile. By default, the limit is math.huge.
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

-- Tries to remove the given amount of ore from the tile at the given position.
-- Returns the ID and actual amount that could be retrieved.
-- If there is no ore left, sets the ID at the given position to no ore (0).
-- Out of bounds access is undefined.
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


--
-- World
--

local World = Object:inherit()
World.Chunk = Chunk

require("world.physics")(World)
require("world.interaction")(World)

-- The ID of air.
World.air = 0
-- The ID of no ore.
World.noOre = 0

-- Initializes a new world with the given width (in tiles).
function World:init(width, gravity)
  assert(width % Chunk.size == 0,
         "world width must be divisible by "..Chunk.size)
  self.chunks = {}
    -- ↑ don't index this directly unless you know what you're doing
  self.width = width
  self.unitWidth = width * Chunk.tileSize
  self.entities = {}
  self.spawnQueue = {}
  self:initPhysics(gravity)
end

-- Packs a chunk position vector into a number.
local function packChunkPosition(position)
  -- This limits chunk coordinates to 16-bit signed integers, but honestly
  -- I don't think anyone will ever try to generate a world that's 65536 chunks
  -- (524288 blocks) in size, as walking across that would take you about
  -- 30 days non-stop.
  return bor(shl(band(position.x, 0xFFFF), 16), band(position.y, 0xFFFF))
end

-- Converts the provided vector to a chunk position.
function World.chunkPosition(v)
  return Vec(math.floor(v.x / Chunk.size), math.floor(v.y / Chunk.size))
end

-- Converts the provided vector to a tile position in a chunk.
function World.positionInChunk(v)
  return Vec(math.floor(v.x % Chunk.size), math.floor(v.y % Chunk.size))
end

-- Converts the provided tile position to a unit position with the specified
-- alignment relative to a tile.
World.unitPosition = {}

function World.unitPosition.topLeft(position)
  return position * Chunk.tileSize
end

function World.unitPosition.center(position)
  local tileSize = Vec(Chunk.tileSize, Chunk.tileSize)
  return position * tileSize + tileSize / 2
end

-- Wraps the given block position around the world seam.
function World:wrapPosition(position)
  return Vec(position.x % self.width, position.y)
end

local wrapPosition = World.wrapPosition

-- Wraps the given chunk position around the world seam.
function World:wrapChunkPosition(position)
  local widthInChunks = self.width / Chunk.size
  return Vec(math.floor(position.x % widthInChunks), math.floor(position.y))
end

local wrapChunkPosition = World.wrapChunkPosition

-- Returns the chunk with the given position. If the chunk doesn't exist,
-- creates one.
function World:ensureChunk(position)
  position = wrapChunkPosition(self, position)
  local packed = packChunkPosition(position)
  if self.chunks[packed] == nil then
    self.chunks[packed] = Chunk:new()
  end
  return self.chunks[packed]
end

-- Returns the chunk with the given position. If the chunk doesn't exist,
-- returns nil.
function World:chunk(position)
  position = wrapChunkPosition(self, position)
  local packed = packChunkPosition(position)
  return self.chunks[packed]
end

-- Marks the chunk at the given position as dirty, which causes it to rebuild
-- its sprite batch when it is about to be drawn.
function World:markDirty(chunkPosition)
  local chunk = self:chunk(chunkPosition)
  if chunk ~= nil then
    chunk.dirty = true
  end
end

local chunkPosition = World.chunkPosition
local positionInChunk = World.positionInChunk

-- Marks all chunks adjacent to the given position dirty.
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

-- Gets the block at the given position.
-- If the position lands outside of any chunks, World.air is returned.
function World:block(position, newBlock)
  position = wrapPosition(self, position)

  local chunk = self:chunk(chunkPosition(position))
  if chunk ~= nil then
    return chunk:block(positionInChunk(position))
  else
    return World.air
  end
end

-- Sets the block at the given position, creating a new chunk if necessary.
-- Returns the old block.
function World:setBlock(position, newBlock)
  position = wrapPosition(self, position)

  local chunk = self:ensureChunk(chunkPosition(position))
  self:markDirtyChunks(position)
  return chunk:setBlock(positionInChunk(position), newBlock)
end

-- Returns the ID and amount of ore at the given position.
-- If the position lands outside of any chunks, (World.noOre, 0) is returned.
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

-- Sets the ID and amount of ore at the given position.
-- Returns the old ID and amount of ore.
-- If the block at the given position is air, no ore is set and
-- (World.noOre, 0) is returned.
function World:setOre(position, id, amount)
  position = wrapPosition(self, position)
  local chunk = self:chunk(chunkPosition(position))
  if cannotHaveOre(chunk, position) then
    return World.noOre, 0
  end

  return chunk:ore(positionInChunk(position))
end

-- Adds an amount of ore to the tile at the given position.
-- Does not override ores with an ID different than the one provided.
-- If limit is specified, the amount of ore will be clamped to that limit.
function World:addOre(position, id, amount, limit)
  position = wrapPosition(self, position)
  local chunk = self:chunk(chunkPosition(position))
  if cannotHaveOre(chunk, position) then
    return
  end

  return chunk:addOre(positionInChunk(position), id, amount, limit)
end

-- Tries to remove the given amount of ore from the tile at the given position.
-- Returns the ID of the ore, and the actual amount removed.
function World:removeOre(position, amount)
  position = wrapPosition(self, position)
  local chunk = self:chunk(chunkPosition(position))
  if cannotHaveOre(chunk, position) then
    return World.noOre, 0
  end

  return chunk:removeOre(positionInChunk(position), amount)
end

-- Returns whether the tile at the given position is an empty (air) tile.
function World:isEmpty(position)
  return self:block(position) == World.air
end

-- Spawns the given entity into the world, returns the entity.
function World:spawn(entity)
  table.insert(self.spawnQueue, entity)
  return entity
end

-- Ticks the world: updates all entities and spawns queued ones.
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
--     print(i, entity)
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
