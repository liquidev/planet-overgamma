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

proc updateToolboxPos(width, height: float) =
  winToolbox.pos = vec2(width - 12 - winToolbox.width, 12)

proc initGUI*() =
  info("Opening", "GUIs")
  wm = newWindowManager(win)
  # TODO: dock, mode wheel
  winGame = wm.newWindow(0, 0, 0, 0, "Game", wkGame)
  wm.add(winGame)
  winHud = wm.newWindow(0, 0, 0, 0, "HUD", wkHud)
  wm.add(winHud)
  winToolbox = wm.newWindow(12, 12, 32, 32, "Toolbox", wkUndecorated)
  winToolbox.draggable = false
  updateToolboxPos(win.width.float, win.height.float)
  win.onResize do (win: RWindow, width, height: Natural):
    updateToolboxPos(width.float, height.float)
  wm.add(winToolbox)
