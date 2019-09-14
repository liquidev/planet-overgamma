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
import ../lang
import ../res
import assembler
import playerdef

proc openInventory*(player: Player) =
  if player.winInventory.isNil:
    let win = wm.newWindow(64, 64, 256 + 31, 256,
                           L"win.inventory title", wkDecorated)
    win.onClose = proc (win: Window): bool =
      player.winInventory = nil
      result = true

    let view = newContainerGrid(15, 32, player.inventory, 8)
    win.add(view)

    wm.add(win)
    player.winInventory = win
  else:
    player.winInventory.close()

proc openAssembler*(player: Player) =
  if player.winAssembler.isNil:
    let win = wm.newWindow(64, 64, 256, 384,
                           L"win.assembler title", wkDecorated)
    win.onClose = proc (win: Window): bool =
      player.recipe = nil
      player.winAssembler = nil
      result = true

    let view = newAssemblerView(14, 32, player)
    win.add(view)

    wm.add(win)
    player.winAssembler = win
  else:
    player.winAssembler.close()

proc updateToolboxPos(width, height: float) =
  winToolbox.pos = vec2(width - 12 - winToolbox.width, 12)

proc initPlayerUI*(player: Player) =
  winToolbox = wm.newWindow(12, 12, 32, 60, L"win.toolbox title", wkUndecorated)
  winToolbox.draggable = false
  updateToolboxPos(win.width.float, win.height.float)
  win.onResize do (width, height: Natural):
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
