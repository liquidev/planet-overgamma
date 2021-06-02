-- Generic resources'n'stuff.
-- This module is split into several other modules to better organize code.
-- Usually it's necessary to require only this directly, as all the other
-- modules operate on the `game` table defined in this module directly and are
-- loaded at the very start of the program.

local Atlas = require "atlas"
local Input = require "input"
local Registry = require "registry"
local Ui = require "ui"
local Vec = require "vec"

---

local atlasSize = Vec(256, 256)

local game = {
  -- globally useful stuff
  input = Input:new(),
  fonts = {}, -- regular, bold
  ui = Ui:new(),

  -- sprites
  playerSprites = {},
  terrainAtlas = Atlas:new(atlasSize),

  -- mods
  mods = {},

  -- block data
  blockIDs = Registry:new(),
  blocks = {},

  -- ore data
  oreIDs = Registry:new(),
  ores = {},

  -- item data
  itemAtlas = Atlas:new(atlasSize),
  itemIDs = Registry:new(),
  items = {},

  -- machine data
  machines = {},

  -- recipe data
  recipes = {},

  -- world generators
  worldGenerators = {},
}

return game
