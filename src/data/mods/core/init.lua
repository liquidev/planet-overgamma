-- The core mod.

local items = require "items"
local World = require "world"

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
local m = {} -- machines

-- paths
local pAssets = "assets"
local pItemAssets = pAssets.."/items"
local pBlockAssets = pAssets.."/blocks"
local pOreAssets = pAssets.."/ores"
local pMachineAssets = pAssets.."/machines"

local function addItem(name)
  i[name] = mod:addItem(name, pItemAssets..'/'..name..".png")
end

local function addBlock(name)
  local callback = mod:addBlock(name, pBlockAssets..'/'..name..".png")
  return function (properties)
    b[name] = callback(properties)
  end
end

local function addOre(name)
  local callback = mod:addOre(name, pOreAssets..'/'..name..".png")
  return function (properties)
    callback(properties)
  end
end

local function addMachine(name)
  local M = require("mods.core.machines."..name)
  m[M.__name] = M
  mod:addMachine(M, pMachineAssets..'/'..M.__name..".png")
end

--
-- Items
--

-- Terrain
addItem "plantMatter"
addItem "stone"

-- Raw materials
addItem "coal"
addItem "rawCopper"
addItem "copper"
addItem "rawTin"
addItem "tin"

-- Chassis
addItem "stoneChassis"

-- Connections
addItem "copperHeatPipe"

--
-- Blocks
--

addBlock "plants" { hardness = 0.75, drops = items.drop(i.plantMatter) }
addBlock "weeds"  { isSolid = false,
                    hardness = 0.5,
                    drops = items.drop(i.plantMatter, 2, 5),
                    attachedTo = World.bottomFace,
                    variants = { density = 1, bias = 1.5 } }
addBlock "rock"   { hardness = 1, drops = items.drop(i.stone),
                    variants = { density = 0.3, bias = 2 } }

--
-- Ores
--

addOre "coal"   { saturatedAt = 10, item = items.stack(i.coal, 5) }
addOre "copper" { saturatedAt = 9, item = items.stack(i.rawCopper, 3) }
addOre "tin"    { saturatedAt = 9, item = items.stack(i.rawTin, 3) }

--
-- Machines
--

addMachine "stone-furnace"
addMachine "stone-refiner"

--
-- Recipes
--

-- blocks
mod:addRecipes {
  ["portAssembler.1"] = {
    {
      name = "block.plants",
      ingredients = { items.stack(i.plantMatter) },
      result = { block = b.plants },
    },
    {
      name = "block.rock",
      ingredients = { items.stack(i.stone) },
      result = { block = b.rock },
    },
  },
}

-- items
mod:addRecipes {
  ["portAssembler.1"] = {
    -- inefficient refining
    {
      name = "item.copper",
      ingredients = { items.stack(i.rawCopper, 1) },
      result = { item = items.stack(i.copper, 1) },
    },
    {
      name = "item.tin",
      ingredients = { items.stack(i.rawTin, 1) },
      result = { item = items.stack(i.tin, 1) },
    },
    -- chassis
    {
      name = "item.stoneChassis",
      ingredients = { items.stack(i.stone, 20) },
      result = { item = items.stack(i.stoneChassis) },
    },
    -- connections
    {
      name = "item.copperHeatPipe",
      ingredients = { items.stack(i.copper, 2) },
      result = { item = items.stack(i.copperHeatPipe) },
    },
  },
}

-- machines
mod:addRecipes {
  ["portAssembler.1"] = {
    {
      name = "machine.stoneFurnace",
      ingredients = { items.stack(i.stoneChassis), items.stack(i.copper),
                      items.stack(i.copperHeatPipe) },
      result = { machine = m.stoneFurnace },
    },
  }
}

--
-- World generation
--

mod:addWorldGenerator(require "mods.core.canon")

--
-- Translations
--

mod:addTranslations()

---

return {
  items = i,
  blocks = b,
}
