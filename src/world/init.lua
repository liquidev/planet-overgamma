-- Game world. This handles all blocks, entities, and body physics.

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

-- Initializes a new world with the given width.
function World:init(width)
  self.chunks = {}
  self.width = width
end

-- Ensures a valid chunk row is available.
local function ensureChunkRow(world, y)
  if world.chunks[y] == nil then
    world.chunks[y] = {}
  end
end

-- Converts the provided vector to a chunk position.
function World.chunkPosition(v)
  return Vec(math.floor(v.x / Chunk.size), math.floor(v.y / Chunk.size))
end

-- Converts the provided vector to a tile position in a chunk.
function World.positionInChunk(v)
  return Vec(math.floor(v.x % Chunk.size), math.floor(v.y % Chunk.size))
end

-- Returns the chunk with the given position. If the chunk doesn't exist,
-- creates one.
function World:ensureChunk(position)
  local x, y = position:xy()
  ensureChunkRow(self, y)
  if self.chunks[y][x] == nil then
    self.chunks[y][x] = Chunk:new()
  end
  return self.chunks[y][x]
end

-- Returns the chunk with the given position. If the chunk doesn't exist,
-- returns nil.
function World:chunk(position)
  local x, y = position:xy()
  if self.chunks[y] == nil then
    return nil
  end
  return self.chunks[y][x]
end

-- Iterates over all chunks in the world and returns (position, chunk) pairs.
function World:chunkPairs()
  -- This can probably be made faster by using the iterator protocol and `next`
  -- directly, but I'm too dumb to figure that out.
  return coroutine.wrap(function ()
    for y, row in pairs(self.chunks) do
      for x, chunk in pairs(row) do
        coroutine.yield(Vec(x, y), chunk)
      end
    end
  end)
end

-- Sets and/or gets the block at the given position.
-- If newBlock is not nil, sets the block at the given position, creating a new
-- chunk if necessary.
-- If the position lands out of bounds, 0 (air) is returned.
function World:block(position, newBlock)
  local chunk
  if newBlock ~= nil then
    chunk = self:ensureChunk(World.chunkPosition(position))
  else
    chunk = self:chunk(World.chunkPosition(position))
  end
  if chunk ~= nil then
    return chunk:block(World.positionInChunk(position), newBlock)
  end
  return 0
end

World.draw = require "world.renderer"

return World
