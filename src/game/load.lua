-- Game resource loading.

local filesystem = love.filesystem
local graphics = love.graphics
local timer = love.timer
local lovector = require "ext.lovector"

local icons = require "icons"
local i18n = require "i18n"
local Mod = require "mod"

---

local game = require "game"

-- Sprite data path.
local pSprites = "data/sprites"

-- Font data path.
local pFonts = "data/fonts"

-- Icon data path.
local pIcons = "data/icons"

-- Loads player sprites and returns a table containing them.
-- The table contains the following fields:
--  · idle: Image - the idle pose, also used as the second frame
--    of the walk cycle
--  · walk: Image – the walking pose, used as the first frame of the walk cycle
--    and as the constant sprite while jumping
--  · fall: Image – the falling pose, used as the constant sprite when the
--    player is falling
local function loadPlayerSprites(color)
  print("game.load: loading '"..color.."' player sprites")
  return {
    idle = graphics.newImage(pSprites.."/player_"..color.."_idle.png"),
    walk = graphics.newImage(pSprites.."/player_"..color.."_walk.png"),
    fall = graphics.newImage(pSprites.."/player_"..color.."_fall.png"),
  }
end

-- Loads a font.
local function loadFont(name, size)
  size = size or 14
  print("game.load: loading font '"..name.."' @ size "..size)
  return graphics.newFont(pFonts..'/'..name..".ttf", size)
end

-- Loads icons.
local function loadIcons()
  local iconsDir = filesystem.getDirectoryItems(pIcons)
  for _, filename in ipairs(iconsDir) do
    if filename:match("%.svg$") then
      local filepath = pIcons..'/'..filename
      local icon = icons.load(filepath)
      local basename = filename:match("(.-)%.svg")
      if basename ~= nil then
        print("game.load: icon '"..basename.."'")
        game.icons[basename] = icon
      else
        print("error loading icon "..filename..": could not extract basename")
      end
    end
  end
end

-- Loads all game resources.
function game.load()
  -- fonts
  game.fonts.regular = loadFont "FiraSans-Regular"
  game.fonts.regular10 = loadFont("FiraSans-Regular", 10)
  game.fonts.bold = loadFont "FiraSans-Bold"
  graphics.setFont(game.fonts.regular)

  -- sprites
  game.playerSprites.blue = loadPlayerSprites "blue"
  loadIcons()

  -- mods
  local start = timer.getTime()
  local errors
  game.mods, errors = Mod.loadMods {}
  if #errors > 0 then
    print("errors occured while loading mods:")
    print(errors)
  end
  print(("mod loading took %.1f ms"):format((timer.getTime() - start) * 1000))

  -- language
  i18n.loadLanguage("eng")
end
