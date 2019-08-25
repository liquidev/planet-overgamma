#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx

import gui/windows
import debug
import res

var
  wm*: WindowManager
  winGame*, winHud*, winToolbox*: Window

proc initGUI*() =
  info("Opening", "GUIs")
  wm = newWindowManager(win)
  # TODO: dock, mode wheel
  winGame = wm.newWindow(0, 0, 0, 0, "Game", wkGame)
  wm.add(winGame)
  winHud = wm.newWindow(0, 0, 0, 0, "HUD", wkHud)
  wm.add(winHud)
