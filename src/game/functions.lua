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
  --   -- Every table inside the outer table is a single variant.
  --   -- Tiles inside are arranged in "bitwise" ordering, that is, each bit in
  --   -- the numeric key represents a connection between this block the blocks
  --   -- surrounding it.
  --   -- The bits are ordered like: Up, Down, Left, Right,
  --   -- from most significant to least significant.
  --   -- If a block doesn't connect to any other blocks, this may simply be
  --   -- filled with the same value repeated 16 times.
  --   variantRects: {{Rect}},
  --   -- Specifies whether the block has collision.
  --   isSolid: boolean,
  --   -- How much laser power the block requires to be broken.
  --   hardness: number,
  --   -- A list of item drops that drop when the block is broken.
  --   drops: {{ id, min, max: number }}
  --   -- Terrain renderer variant config.
  --   -- density specifies how dense the noise used to sample variants
  --   -- should be.
  --   -- bias specifies the power to which the sampled noise value should be
  --   -- raised, in order to make it more (or less) likely that lower variants
  --   -- are picked.
  --   variants: { density, bias: number },
  --   -- Specifies which solid faces a block is attached to.
  --   -- If any of the faces become non-solid and the block gets updated,
  --   -- the block will be broken.
  --   attachedTo: number,
  -- }
  -- This data structure is generated automatically when using Mod:addBlock.

  if Registry.hasKey(game.blockIDs, key) then
    error("block '"..key.."' is already registered")
  end
  local id = game.blockIDs[key]
  block.id = id

  -- Generate quads, for use by the renderer.
  -- This should save some allocations later.
  block.variantQuads = {}
  for i, rects in ipairs(block.variantRects) do
    local quads = {}
    for j, rect in ipairs(rects) do
      quads[j] = graphics.newQuad(rect.x, rect.y, rect.width, rect.height,
                                  game.blockAtlas.image)
    end
    block.variantQuads[i] = quads
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

-- Adds a new recipe into the game.
-- Since recipes do not have unique names or IDs, this doesn't return anything.
--
-- An extra field `target`, containing the target parameter's value, is added to
-- the recipe table after successful registration.
--
-- Just like the other functions, prefer Mod:addRecipe over this.
function game.addRecipe(target, recipe)
  -- The recipe table has to have the following structure:
  -- {
  --   -- A name for the recipe. This is only really used for debugging
  --   -- purposes, and defaults to "unnamed" if left out.
  --   name: string | nil,
  --   -- A table of item stacks. These are the ingredients required to use
  --   -- this recipe, and are consumed upon usage.
  --   ingredients: {{ id: number, amount: number }},
  --   -- The result of the recipe. This is interpreted by the recipe target
  --   -- and does not have a well-defined meaning.
  --   result: any,
  -- }

  if game.recipes[target] == nil then
    game.recipes[target] = {}
  end
  recipe.name = recipe.name or "unnamed"
  recipe.target = target
  table.insert(game.recipes[target], recipe)
  print("game: registered recipe '"..recipe.name.."'")
end

-- Gets the list of available recipes for the given target.
-- Returns an empty table if no recipes were ever registered for the target.
function game.getRecipes(target)
  return game.recipes[target] or {}
end

-- Adds a world generator to the game.
-- Errors out if another world generator with the generator's name
-- already exists.
--
-- Note that the names of generators added by Mod:addWorldGenerator get
-- namespaced, so conflicts between two mods with a generator with the same name
-- will not occur.
function game.addWorldGenerator(generator)
  assert(game.worldGenerators[generator.name] == nil,
         "world generator '"..generator.name.."' is already registered")
  game.worldGenerators[generator.name] = generator
  print("game: registered world generator '"..generator.name.."'")
end

return game
