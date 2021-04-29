-- The world renderer. Imported as World:draw by world.lua.

local graphics = love.graphics

local game = require "game"
local Rect = require "rect"
local Vec = require "vec"

---

-- Returns whether blockA tiles with blockB. Both arguments must be valid
-- block IDs.
local function tilesWith(blockA, blockB)
  return game.blocks[blockA].tilesWith[blockB] ~= nil
end

-- Returns the bitwise tiling index for the tile at the given position.
local function bitwiseTilingIndex(self, position, blockID)
  local x, y = position:xy()
  local bits = 0
  if tilesWith(blockID, self:block(Vec(x, y - 1))) then
    bits = bits + 8
  end
  if tilesWith(blockID, self:block(Vec(x, y + 1))) then
    bits = bits + 4
  end
  if tilesWith(blockID, self:block(Vec(x - 1, y))) then
    bits = bits + 2
  end
  if tilesWith(blockID, self:block(Vec(x + 1, y))) then
    bits = bits + 1
  end
  return bits + 1
end

-- Rebuilds chunk's sprite batch, if necessary.
local function rebuildBlockBatch(self, chunkPosition, chunk)
  if not chunk.dirty then return end

  local blockAtlas = game.blockAtlas.image

  if chunk.blockBatch == nil then
    chunk.blockBatch = graphics.newSpriteBatch(blockAtlas, chunk.size^2)
  end

  chunk.blockBatch:clear()
  for y = 0, chunk.size - 1 do
    for x = 0, chunk.size - 1 do
      local positionInChunk = Vec(x, y)
      local positionInWorld = chunkPosition * chunk.size + positionInChunk
      local blockID = chunk:block(positionInChunk)
      if blockID ~= 0 then
        local block = game.blocks[blockID]
        local index = bitwiseTilingIndex(self, positionInWorld, blockID)
        local quad = block.quads[index]
        chunk.blockBatch:add(quad, (positionInChunk * chunk.tileSize):xy())
      end
    end
  end

  chunk.dirty = false
end

local function render(self, alpha, viewport)
  local Chunk = self.Chunk

  local left = math.floor(viewport:left() / Chunk.unitSize)
  local top = math.floor(viewport:top() / Chunk.unitSize)
  local right = math.floor(viewport:right() / Chunk.unitSize)
  local bottom = math.floor(viewport:bottom() / Chunk.unitSize)

  -- chunks
  for y = top, bottom do
    for x = left, right do
      local chunkPosition = Vec(x, y)
      local chunk = self:chunk(chunkPosition)
      if chunk ~= nil then
        rebuildBlockBatch(self, chunkPosition, chunk)
        local blocks = chunk.blockBatch
        if blocks ~= nil then
          graphics.draw(blocks, (chunkPosition * chunk.unitSize):xy())
        end
      end
    end
  end

  -- entities
  for _, entity in ipairs(self.entities) do
    entity:draw(alpha)
  end
end

-- Renders the world. This function is available publicly as World:draw.
return function (self, alpha, camera)
  camera:transform(render, nil, self, alpha, camera:viewport())
end
