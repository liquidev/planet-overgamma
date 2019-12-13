import strutils
import tables
import times

import rapid/gfx
import rapid/gfx/text
import rapid/world/tilemap
import rdgui/windows

import gui
import res
import res/loader
import world/worldsave

proc main() =
  preload()
  initWindow()
  load()

  var
    fps, fpsCounter = 0
    fpsLastCheck = time()

  sur.loop:
    init ctx:
      if settings.graphics.msaa > 0:
        ctx.antialiasing = true
    draw ctx, step:
      ctx.clear(gray(0))

      let start = time()

      wm.draw(ctx, step)

      inc(fpsCounter)
      if time() - fpsLastCheck > 1:
        fps = fpsCounter
        fpsCounter = 0
        fpsLastCheck = time()

      if args.hasKey("debug.showDrawTime"):
        let drawTime = time() - start
        ctx.text(firaSans, 8, 8,
          formatFloat(drawTime * 1000, ffDecimal, 3) & " ms (" &
          formatFloat(1 / drawTime, ffDecimal, 1) & " pfps)\n" &
          $fps & " fps")
    update step:
      currentSave.overworld.update(step)

when isMainModule: main()
