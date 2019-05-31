#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import math
import random
import tables
import times

import rapid/gfx/surface
import rapid/gfx/text
import rapid/world/tilemap

import res/resources
import res/loader
import world/world
import world/worldconfig
import world/worldsave

proc main() =
  loadCmdline()
  initWindow()
  load()

  gfx.loop:
    draw ctx, step:
      var start = time()
      ctx.clear(rgb(0, 0, 0))
      currentSave.overworld.draw(ctx, step)
      if args.hasKey("debug.overlay"):
        ctx.text(firaSans14, 8, 8,
          "frame time [ms]: " & $((time() - start) * 1000) & "\n" &
          "player pos: " & $currentSave.overworld["player"].pos)
    update step:
      currentSave.overworld.update(step)

when isMainModule: main()
