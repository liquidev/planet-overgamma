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
  self.blocks = tables.fill({}, Chunk.size^2, 0)
end

-- Sets and/or gets the block ID at the given position. The position must be in
-- the chunk's boundaries, otherwise behavior is undefined for
-- better performance.
-- If newBlock is not nil, sets the block at that position and returns the
-- previous block.
function Chunk:block(position, newBlock)
  local x, y = position:xy()
  local i = 1 + x + y * Chunk.size
  local old = self.blocks[i]
  if newBlock ~= nil then
    self.blocks[i] = newBlock
    self.dirty = true
  end
  return old
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

-- Marks all chunks adjacent to the given position dirty.
function World:markDirtyChunks(position)
  local chunkPosition = World.chunkPosition(position)
  local positionInChunk = World.positionInChunk(position)
  self:markDirty(chunkPosition)
  if positionInChunk.x == 0 then
    self:markDirty(chunkPosition + Vec(-1, 0))
  end
  if positionInChunk.x == Chunk.size - 1 then
    self:markDirty(chunkPosition + Vec(1, 0))
  end
  if positionInChunk.y == 0 then
    self:markDirty(chunkPosition + Vec(0, -1))
  end
  if positionInChunk.y == Chunk.size - 1 then
    self:markDirty(chunkPosition + Vec(0, 1))
  end
end

-- Sets and/or gets the block at the given position.
-- If newBlock is not nil, sets the block at the given position, creating a new
-- chunk if necessary.
-- If the position lands outside of any chunks, World.air is returned.
function World:block(position, newBlock)
  position = wrapPosition(self, position)

  local chunk
  if newBlock ~= nil then
    chunk = self:ensureChunk(World.chunkPosition(position))
  else
    chunk = self:chunk(World.chunkPosition(position))
  end
  if chunk ~= nil then
    if newBlock ~= nil then
      self:markDirtyChunks(position)
    end
    return chunk:block(World.positionInChunk(position), newBlock)
  end
  return World.air
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
