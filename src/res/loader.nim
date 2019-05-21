#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx/surface

import ../world/worldsave
import ../colors

include
  loader/loadcmd,
  loader/loadfonts,
  loader/loadterrain

proc load*() =
  info("Loading", "shared resources")
  loadColors()
  terrainData = loadTerrain(terrain)
  loadFonts()
  info("Loading", "finished shared resources")
  if args.hasKey("debug.autostart"):
    warn("Warn.Save:", "beginning the game through --debug.autostart")
    let seed = int64(epochTime() * 1000000000.0)
    info("Save", "seed = ", seed)
    currentSave = newSave(seed)

proc initWindow*() =
  win = initRWindow()
    .size(1280, 720)
    .title("Planet Overgamma " &
      "(compiled " & CompileDate & " " & CompileTime & " UTC)")
    .open()
  gfx = win.openGfx()
