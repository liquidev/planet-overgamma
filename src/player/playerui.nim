#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import glm/vec
import rapid/gfx

import ../gui
import ../gui/[control, button, containerview]
import ../gui/windows
import ../res
import playerdef

proc openInventory*(player: Player) =
  if player.winInventory.isNil:
    let win = wm.newWindow(64, 64, 192, 256, "Inventory", wkDecorated)
    win.onClose = proc (win: Window): bool =
      player.winInventory = nil
      result = true
    let view = newContainerGrid(14, 32, player.inventory, 5)
    win.add(view)
    wm.add(win)
    player.winInventory = win
  else:
    player.winInventory.close()

proc openAssembler*(player: Player) =
  if player.winAssembler.isNil:
    let win = wm.newWindow(64, 64, 192, 256, "portAssembler", wkDecorated)
    win.onClose = proc (win: Window): bool =
      player.winAssembler = nil
      result = true
    wm.add(win)
    player.winAssembler = win
  else:
    player.winAssembler.close()

proc updateToolboxPos(width, height: float) =
  winToolbox.pos = vec2(width - 12 - winToolbox.width, 12)

proc initPlayerUI*(player: Player) =
  winToolbox = wm.newWindow(12, 12, 32, 60, "Toolbox", wkUndecorated)
  winToolbox.draggable = false
  updateToolboxPos(win.width.float, win.height.float)
  win.onResize do (win: RWindow, width, height: Natural):
    updateToolboxPos(width.float, height.float)
  wm.add(winToolbox)

  var inventoryButton = newButton(4, 4, 24, 24, "inventory", ButtonDock)
  inventoryButton.onClick = proc (btn: Button) =
    player.openInventory()

  var assemblerButton = newButton(4, 32, 24, 24, "assembler", ButtonDock)
  assemblerButton.onClick = proc (btn: Button) =
    player.openAssembler()

  winToolbox.add(inventoryButton)
  winToolbox.add(assemblerButton)
