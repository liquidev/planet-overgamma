#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx

import ../world/worldsave
import ../colors

include
  loader/loadcmd,
  loader/loadeffects,
  loader/loadfonts,
  loader/loadsprites,
  loader/loadterrain

proc load*() =
  info("Loading", "shared resources")
  loadColors()
  terrainData = loadTerrain(terrain)
  loadSprites()
  loadFonts()
  loadEffects()
  info("Loading", "finished shared resources")
  if args.hasKey("debug.autostart"):
    warn("Warning:", "beginning the game through --debug.autostart")
    let seed = int64(epochTime() * 1000000000.0)
    info("Save", "seed = ", seed)
    currentSave = newSave(seed)

proc initWindow*() =
  win = initRWindow()
    .size(1280, 720)
    .title("Planet Overgamma")
    .open()
  sur = win.openGfx()
