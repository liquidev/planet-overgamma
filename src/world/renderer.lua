-- The world renderer. Imported as World:draw by world.lua.

local graphics = love.graphics
local lmath = love.math

local common = require "common"
local game = require "game"
local Rect = require "rect"
local Vec = require "vec"

local lerp = common.lerp

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
  chunkPosition = self:wrapChunkPosition(chunkPosition)

  local terrainAtlas = game.terrainAtlas.image

  if chunk.terrainBatch == nil then
    chunk.terrainBatch = graphics.newSpriteBatch(terrainAtlas, chunk.size^2)
  end

  chunk.terrainBatch:clear()
  for y = 0, chunk.size - 1 do
    for x = 0, chunk.size - 1 do
      local positionInChunk = Vec(x, y)
      local positionInWorld = chunkPosition * chunk.size + positionInChunk
      local unitX, unitY = (positionInChunk * chunk.tileSize):xy()

      local blockID = chunk:block(positionInChunk)
      local oreID, oreAmount = chunk:ore(positionInChunk)

      -- blocks
      if blockID ~= 0 then
        local block = game.blocks[blockID]
        local tileIndex = bitwiseTilingIndex(self, positionInWorld, blockID)
        local quad
        if #block.variantQuads > 1 then
          local config = block.variants or {}
          local density, bias = config.density or 1, config.bias or 1
          local noisePosition = positionInWorld * density + Vec(0.01, 0.01)
          local variantIndex
          if oreID == 0 then
            local noise = lmath.noise(noisePosition.x, noisePosition.y) ^ bias
            variantIndex = math.floor(lerp(1, #block.variantQuads, noise) + 0.5)
          else
            variantIndex = 1
          end
          quad = block.variantQuads[variantIndex][tileIndex]
        else
          quad = block.variantQuads[1][tileIndex]
        end
        chunk.terrainBatch:add(quad, unitX, unitY)
      end

      -- ores
      if oreID ~= 0 then
        local ore = game.ores[oreID]
        local saturation =
          common.clamp((oreAmount - 10) / (ore.saturatedAt - 10), 0, 1)
        local quadIndex = math.ceil(saturation * (#ore.quads - 1)) + 1
        local quad = ore.quads[quadIndex]
        chunk.terrainBatch:add(quad, unitX, unitY)
      end
    end
  end

  chunk.dirty = false
end

-- Draws entities from the given table.
local function drawEntities(entities, alpha)
  for _, entity in ipairs(entities) do
    entity:draw(alpha)
  end
end

-- Untransformed world rendering.
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
        local terrain = chunk.terrainBatch
        if terrain ~= nil then
          graphics.draw(terrain, (chunkPosition * chunk.unitSize):xy())
        end
      end
    end
  end

  -- entities
  local entities = self.entities
  drawEntities(entities, alpha)
  if left <= 0 then
    graphics.push()
    graphics.translate(-self.unitWidth, 0)
    drawEntities(entities, alpha)
    graphics.pop()
  end
  if right >= self.width / Chunk.size then
    graphics.push()
    graphics.translate(self.unitWidth, 0)
    drawEntities(entities, alpha)
    graphics.pop()
  end
end

-- Renders the world. This function is available publicly as World:draw.
return function (self, alpha, camera)
  camera:transform(render, self, alpha, camera:viewport())
end
