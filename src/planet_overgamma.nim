#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) iLiquid, 2018-2019
#--

import rapid/gfx/surface

import sharedres

proc main() =
  var
    win = initRWindow()
      .size(1024, 576)
      .title("Planet Overgamma " &
        "(compiled " & CompileDate & " " & CompileTime & " UTC)")
      .open()
    gfx = win.openGfx()

  load()

  gfx.loop:
    draw ctx, step:
      discard
    update step:
      discard

when isMainModule: main()
