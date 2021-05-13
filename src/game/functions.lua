-- Resource handling module. This is split into several modules to prevent
-- recursive requires and help better organize the code.

local graphics = love.graphics

local Registry = require "registry"

---

local game = require "game"
require "game.load"

-- Adds a new block into the game and returns its ID and `block`.
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
  local id = game.blockIDs[key]
  block.id = id

  -- Generate quads, for use by the renderer.
  -- This should save some allocations later.
  block.quads = {}
  for i, rect in ipairs(block.rects) do
    block.quads[i] = graphics.newQuad(rect.x, rect.y, rect.width, rect.height,
                                      game.blockAtlas.image)
  end

  game.blocks[id] = block
  print("game: registered block '"..key.."' -> "..id)
  return id, block
end

-- Adds a new item into the game and returns its ID and `item`.
-- Raises an error if an item with the given key already exists.
--
-- Just like game.addBlock, the item table is modified to also contain the
-- item's ID, and Mod:addItem should be preferred over this.
function game.addItem(key, item)
  -- The item table has to have the following structure:
  -- {
  --   -- The game.itemAtlas rect of the item.
  --   rect: {Rect},
  -- }
  -- which is generated automatically by Mod:addItem.
  if Registry.hasKey(game.itemIDs, key) then
    error("item '"..key.."' is already registered")
  end
  local id = game.itemIDs[key]
  item.id = id

  -- Generate the item's quad.
  local rect = item.rect
  item.quad = graphics.newQuad(rect.x, rect.y, rect.width, rect.height,
                               game.itemAtlas.image)

  game.items[id] = item
  print("game: registered item '"..key.."' -> "..id)
  return id, item
end

return game
