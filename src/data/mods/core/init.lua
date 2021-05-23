-- The core mod.

local items = require "items"

---

local mod = ...
mod:metadata {
  name = "Core",
  version = "0.1.0",
  author = "liquidev",
  description = "The core mechanics of the game.",
}

-- I don't normally abbreviate names to single letters, but it's done here
-- for convenience as typing `item.plantMatter` gets old pretty quick.
local i = {} -- items
local b = {} -- blocks

local function addItem(name)
  i[name] = mod:addItem(name, "items/"..name..".png")
end

local function addBlock(name)
  local callback = mod:addBlock(name, "blocks/"..name..".png")
  return function (properties)
    b[name] = callback(properties)
  end
end

addItem "plantMatter"
addItem "stone"

addBlock "plants" { hardness = 0.75, drops = items.drop(i.plantMatter) }
addBlock "rock"   { hardness = 1, drops = items.drop(i.stone),
                    variants = { density = 0.3, bias = 2 } }

mod:addRecipes {
  ["portAssembler.1"] = {
    {
      name = "block.plants",
      ingredients = { items.stack(i.plantMatter) },
      result = b.plants,
    },
    {
      name = "block.rock",
      ingredients = { items.stack(i.stone) },
      result = b.rock,
    },
  },
}

mod:addWorldGenerator(require "mods.core.canon")

mod:addTranslations()

return {
  items = i,
  blocks = b,
}
