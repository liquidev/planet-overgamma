-- Generic resources'n'stuff.

local Atlas = require "atlas"
local Input = require "input"
local Registry = require "registry"
local Vec = require "vec"

---

local atlasSize = Vec(256, 256)

local game = {
  -- globally useful stuff
  input = Input:new(),

  -- block data
  blockAtlas = Atlas:new(atlasSize),
  blockIDs = Registry:new(),
  blocks = {},
}

-- Adds a new block into the game and returns `block` and its ID.
-- Raises an error if a block with the given key already exists.
--
-- The provided `block` table is modified to also contain the block ID.
--
-- This shouldn't be used directly by mods. Instead, Mod:addBlock should be
-- preferred.
function game.addBlock(key, block)
  -- block follows this data structure:
  -- {
  --   -- This is the set of atlas rects for this block.
  --   -- They are arranged in "bitwise" ordering, that is, each bit in the
  --   -- numeric key represents a connection between this block the blocks
  --   -- surrounding it.
  --   -- The bits are ordered like: Up, Down, Left, Right,
  --   -- from most significant to least significant.
  --   -- If a block doesn't connect to any other blocks, this may simply be
  --   -- filled with the same value repeated 16 times.
  --   rects: {Rect},
  -- }
  -- This data structure is generated automatically when using Mod:addBlock.

  if Registry.hasKey(game.blockIDs, key) then
    error("block '"..key.."' is already registered")
  end
  block.id = game.blockIDs[key]
  game.blocks[key] = block
  print("game: registered block '"..key.."'")
  return block, block.id
end

return game
