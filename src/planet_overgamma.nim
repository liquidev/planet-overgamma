#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx/surface
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
      ctx.clear(rgb(0, 0, 0))
      currentSave.overworld.draw(ctx, step)
    update step:
      currentSave.overworld.update(step)

when isMainModule: main()
