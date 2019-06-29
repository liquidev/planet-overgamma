#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import math
import random
import tables
import times

import rapid/gfx
import rapid/gfx/text
import rapid/world/tilemap

import gui
import gui/windows
import res
import res/loader
import world/world
import world/worldconfig
import world/worldsave

proc main() =
  loadCmdline()
  initWindow()
  load()

  sur.loop:
    draw ctx, step:
      ctx.clear(rgb(0, 0, 0))

      let start = epochTime()

      wm.draw(ctx, step)

      if args.hasKey("debug.overlay"):
        ctx.text(firaSans14, 8, 8,
          "Planet Overgamma devel – compiled on " &
            CompileDate & " " & CompileTime & " UTC\n" &
          "frame time [ms]: " & $((epochTime() - start) * 1000) & "\n" &
          "player pos: " & $currentSave.overworld["player"].pos)
    update step:
      currentSave.overworld.update(step)

when isMainModule: main()
