import rdgui/windows

import gui/powindows
import debug
import res

var
  wm*: WindowManager
  winGame*: GameWindow
  winHud*, winToolbox*: Window

proc initGUI*() =
  info("Opening", "GUIs")
  wm = newWindowManager(win)
  # TODO: mode wheel
  winGame = wm.newGameWindow()
  wm.add(winGame)
  winHud = wm.newWindow(0, 0, 0, 0)
  wm.add(winHud)

