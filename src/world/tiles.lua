-- Things, queries, and utilities related to tiles.

local image = love.image

local Vec = require "vec"

---

local tiles = {}

-- Mapping from tile bit-indices to positions on a 4x4 block tilemap.
local indexBitsToPosition = {
  --             bits: UDLR
  [0]  = Vec(3, 3), -- 0000
  [1]  = Vec(2, 3), -- 0001
  [2]  = Vec(0, 3), -- 0010
  [3]  = Vec(1, 3), -- 0011
  [4]  = Vec(3, 0), -- 0100
  [5]  = Vec(0, 0), -- 0101
  [6]  = Vec(2, 0), -- 0110
  [7]  = Vec(1, 0), -- 0111
  [8]  = Vec(3, 2), -- 1000
  [9]  = Vec(0, 2), -- 1001
  [10] = Vec(2, 2), -- 1010
  [11] = Vec(1, 2), -- 1011
  [12] = Vec(3, 1), -- 1100
  [13] = Vec(0, 1), -- 1101
  [14] = Vec(2, 1), -- 1110
  [15] = Vec(1, 1), -- 1111
}

-- Disassembles the imageData into 16 distinct tiles, as described in mod.lua,
-- and packs them into the provided atlas, filling the provided `rects` table
-- with rectangles packed into the atlas.
-- Returns the modified `rects` table.
function tiles.packBlock(rects, atlas, imageData)
  local imageWidth, imageHeight = imageData:getDimensions()
  local tileWidth, tileHeight = imageWidth / 4, imageHeight / 4
  for indexBits, position in ipairs(indexBitsToPosition) do
    local tile = image.newImageData(tileWidth, tileHeight)
    position = position * Vec(tileWidth, tileHeight)
    tile:paste(imageData, position.x, position.y, tileWidth, tileHeight)
    local rect = atlas:pack(tile)
    rects[indexBits] = rect
  end
  return rects
end

return tiles
