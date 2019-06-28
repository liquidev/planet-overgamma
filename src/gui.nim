#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import gui/windows
import res

var
  wm*: WindowManager

proc initGUI*() =
  wm = newWindowManager(win)
  # TODO: this is debug stuff, remove this
  let
    w1 = wm.newWindow(128, 128, 128, 128, "testing 1", wkUndecorated)
    w2 = wm.newWindow(128, 256, 128, 128, "testing 2", wkUndecorated)
  wm.add(w1)
  wm.add(w2)
