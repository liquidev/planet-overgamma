#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import json

import rapid/gfx

import ../player/recipedb
import ../world/tiledb as tdb
import ../world/worldsave
import ../colors
import ../gui
import ../lang

include
  loader/loadcmd,
  loader/loadeffects,
  loader/loadfonts,
  loader/loadicons,
  loader/loaditems,
  loader/loadsprites,
  loader/loadterrain

proc load*() =
  info("Loading", "settings")
  settings = json.parseFile(Data/"settings.json").to(Settings)
  info("Loading", "shared resources")
  loadColors()
  terrainData = loadTerrain(terrain)
  loadSprites()
  itemSpriteData = loadItems(itemSprites)
  loadIcons()
  loadFonts()
  loadEffects()
  tiles = loadTileDatabase(Data/"tiles/tiles.json")
  recipes = loadRecipeDatabase(Data/"tiles/recipes.json")
  loadLanguage()
  info("Loading", "finished shared resources")
  initGUI()

  if args.hasKey("debug.autostart"):
    warn("Warning:", "beginning the game through --debug.autostart")
    let seed = int64 epochTime() * 1_000_000_000
    info("Save", "seed = ", seed)
    currentSave = newSave(seed)
    winGame.gameWorld = currentSave.overworld

proc initWindow*() =
  win = initRWindow()
    .size(1280, 720)
    .title("Planet Overgamma")
    .antialiasLevel(settings.graphics.msaa)
    .open()
  sur = win.openGfx()
