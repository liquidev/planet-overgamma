-- Things, queries, and utilities related to tiles.

local graphics = love.graphics
local image = love.image

local tables = require "tables"
local Vec = require "vec"

---

local tiles = {}

-- Mapping from tile bit-indices to positions on a 4x4 block tilemap.
local indexBitsToPosition = {
  -- Note that keys have 1 added to them so that this produces
  -- numeric-indexed tables. This is done to improve performance.
  --             bits: UDLR
  [1]  = Vec(3, 3), -- 0000
  [2]  = Vec(0, 3), -- 0001
  [3]  = Vec(2, 3), -- 0010
  [4]  = Vec(1, 3), -- 0011
  [5]  = Vec(3, 0), -- 0100
  [6]  = Vec(0, 0), -- 0101
  [7]  = Vec(2, 0), -- 0110
  [8]  = Vec(1, 0), -- 0111
  [9]  = Vec(3, 2), -- 1000
  [10] = Vec(0, 2), -- 1001
  [11] = Vec(2, 2), -- 1010
  [12] = Vec(1, 2), -- 1011
  [13] = Vec(3, 1), -- 1100
  [14] = Vec(0, 1), -- 1101
  [15] = Vec(2, 1), -- 1110
  [16] = Vec(1, 1), -- 1111
}

-- Disassembles the single block image into separate block variants
-- and packs them into the provided atlas, filling the provided `variants` table
-- with tables of rectangles packed into the atlas.
-- Returns the modified `variants` table.
function tiles.packBlock(variants, atlas, imageData)
  local imageWidth, imageHeight = imageData:getDimensions()
  local variantCount = imageWidth / imageHeight

  if variantCount == 1 then
    local rect = atlas:pack(imageData)
    variants[1] = tables.fill({}, 16, rect)
  else
    for i = 1, variantCount do
      local tile = image.newImageData(imageHeight, imageHeight)
      tile:paste(imageData, 0, 0,
                 (i - 1) * imageHeight, 0, imageHeight, imageHeight)
      variants[i] = tables.fill({}, 16, atlas:pack(tile))
    end
  end

  return variants
end

-- Disassembles the imageData into 16 distinct tiles, as described in mod.lua,
-- and packs them into the provided atlas, filling the provided `variants` table
-- with tables of rectangles packed into the atlas.
-- Returns the modified `variants` table.
function tiles.pack4x4(variants, atlas, imageData)
  local imageWidth, imageHeight = imageData:getDimensions()
  local variantCount = imageWidth / imageHeight
  local tileSize = imageHeight / 4

  for i = 1, variantCount do
    local rects = {}
    for indexBits, position in ipairs(indexBitsToPosition) do
      local tile = image.newImageData(tileSize, tileSize)
      position = position:dup()
      position:add(Vec((i - 1) * 4, 0))
      position:mul(tileSize)
      tile:paste(imageData, 0, 0, position.x, position.y, tileSize, tileSize)
      local rect = atlas:pack(tile)
      rects[indexBits] = rect
    end
    variants[i] = rects
  end

  return variants
end

-- Disassembles the imageData containing a horizontal strip of ore tiles into
-- a set of ore sprites, and packs them into the provided atlas, filling the
-- `rects` table with rectangles packed into the atlas.
-- Returns the modified `rects` table.
function tiles.packOre(rects, atlas, imageData)
  local imageWidth, imageHeight = imageData:getDimensions()
  local saturationCount = imageWidth / imageHeight

  for i = 1, saturationCount do
    local tile = image.newImageData(imageHeight, imageHeight)
    tile:paste(imageData, 0, 0,
               (i - 1) * imageHeight, 0, imageHeight, imageHeight)
    rects[i] = atlas:pack(tile)
  end

  return rects
end

-- Extracts machine sprites from the given imageData into the images table.
-- Returns the modified images table.
function tiles.extractMachineSprites(sprites, imageData)
  local imageWidth, imageHeight = imageData:getDimensions()
  local spriteCount = imageWidth / imageHeight

  for i = 1, spriteCount do
    local tile = image.newImageData(imageHeight, imageHeight)
    tile:paste(imageData, 0, 0,
               (i - 1) * imageHeight, 0, imageHeight, imageHeight)
    sprites[i] = graphics.newImage(tile)
  end

  return sprites
end

return tiles
