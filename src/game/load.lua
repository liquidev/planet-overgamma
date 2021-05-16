-- Game resource loading.

local graphics = love.graphics

local Mod = require "mod"

---

local game = require "game"

-- Sprite data path.
local pSprites = "data/sprites"

-- Font data path.
local pFonts = "data/fonts"

-- Loads player sprites and returns a table containing them.
-- The table contains the following fields: {idle, walk, fall}.
local function loadPlayerSprites(color)
  print("game.load: loading '"..color.."' player sprites")
  return {
    idle = graphics.newImage(pSprites.."/player_"..color.."_idle.png"),
    walk = graphics.newImage(pSprites.."/player_"..color.."_walk.png"),
    fall = graphics.newImage(pSprites.."/player_"..color.."_fall.png"),
  }
end

-- Loads a font.
local function loadFont(name)
  print("game.load: loading font '"..name.."'")
  return graphics.newFont(pFonts..'/'..name..".ttf", 14)
end

-- Loads all game resources.
function game.load()
  -- fonts
  game.fonts.regular = loadFont "FiraSans-Regular"
  game.fonts.bold = loadFont "FiraSans-Bold"
  graphics.setFont(game.fonts.regular)

  -- sprites
  game.playerSprites.blue = loadPlayerSprites "blue"

  -- mods
  local errors
  game.mods, errors = Mod.loadMods {}
  if #errors > 0 then
    print("errors occured while loading mods:")
    print(errors)
  end
end
