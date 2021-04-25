-- Game world. This handles all tiles, entities, and body physics.

local Object = require "object"
local tables = require "tables"
local Vec = require "vec"

--
-- Chunk
--

local Chunk = Object:inherit()
Chunk.size = 8

-- Initializes a new chunk.
function Chunk:init()
  self.tiles = tables.fill({}, 0)
end

-- Returns the tile at the given position. The position must be in the chunk's
-- boundaries, otherwise this returns nil.
function Chunk:tile(position)
  local x, y = position:xy()
  if x >= 0 and x < Chunk.size and y >= 0 and y < Chunk.size then
    return self.tiles[x + y * Chunk.size]
  end
end

--
-- World
--

local World = Object:inherit()
World.Chunk = Chunk

-- Initializes a new world.
function World:init()
  self.chunks = {}
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

-- Returns the chunk at the given position. If the chunk doesn't exist,
-- creates one.
function World:ensureChunk(position)
  local x, y = position:xy()
  ensureChunkRow(self, y)
  if self.chunks[y][x] == nil then
    self.chunks[y][x] = Chunk:new()
  end
  return self.chunks[y][x]
end

-- Returns the chunk at the given position. If the chunk doesn't exist,
-- returns nil.
function World:chunk(position)
  local x, y = position:xy()
  if self.chunks[y] == nil then
    return nil
  end
  return self.chunks[y][x]
end

return World
