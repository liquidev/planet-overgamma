import json

import rapid/gfx

import ../player/recipedb
import ../world/tiledb as tdb
import ../world/worldsave
import ../colors
import ../gui
import ../lang
import ../mods/modloader

include
  loader/loadcmd,
  loader/loadeffects,
  loader/loadfonts,
  loader/loadicons,
  loader/loaditems,
  loader/loadsprites,
  loader/loadterrain

proc preload*() =
  info("Loading", "settings")
  settings = json.parseFile(Data/"settings.json").to(Settings)
  loadCmdline()

proc load*() =
  info("Loading", "core resources")
  loadColors()
  mods.loadMods("mods")
  loadSprites()
  itemSpriteData = loadItems(itemSprites)
  loadIcons()
  loadFonts()
  loadEffects()
  tiles = newTileDatabase()
  recipes = loadRecipeDatabase(Data/"tiles/recipes.json")
  loadLanguage("data/lang")
  info("Loading", "finished core resources")
  initGUI()
  mods.initMods()

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
  sur.vsync = settings.graphics.vsync
