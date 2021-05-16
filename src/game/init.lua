-- Generic resources'n'stuff.
-- This module is split into several other modules to better organize code.
-- Usually it's only necessary to only require this directly, as all the other
-- modules operate on the `game` table defined in this module directly and are
-- loaded at the very start of the program.

local Atlas = require "atlas"
local Input = require "input"
local Registry = require "registry"
local Vec = require "vec"

---

local atlasSize = Vec(256, 256)

local game = {
  -- globally useful stuff
  input = Input:new(),
  fonts = {}, -- regular, bold

  -- sprites
  playerSprites = {},

  -- mods
  mods = {},

  -- block data
  blockAtlas = Atlas:new(atlasSize),
  blockIDs = Registry:new(),
  blocks = {},

  -- item data
  itemAtlas = Atlas:new(atlasSize),
  itemIDs = Registry:new(),
  items = {},
}

return game
