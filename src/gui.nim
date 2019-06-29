#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import debug
import res
import gui/windows

var
  wm*: WindowManager
  winGame*: Window

proc initGUI*() =
  info("Opening", "GUIs")
  wm = newWindowManager(win)
  # TODO: dock, mode wheel
  winGame = wm.newWindow(0, 0, 0, 0, "Game window", wkGame)
  wm.add(winGame)
