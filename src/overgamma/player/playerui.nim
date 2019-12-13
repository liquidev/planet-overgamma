import glm/vec
import rapid/gfx
import rdgui/button
import rdgui/control
import rdgui/windows

import ../gui
import ../gui/pobutton
import ../gui/powindows
import ../gui/storageview
import ../lang
import ../res
import assembler
import playerdef

proc openInventory*(player: Player) =
  if player.winInventory.isNil:
    let win = wm.newUserWindow(64, 64, 320, 480, L"win.inventory title")
    win.onClose = proc (): bool =
      player.winInventory = nil
      result = true

    let view = newStorageView(15, 32, player.inventory, 8)
    win.add(view)

    wm.add(win)
    player.winInventory = win
  else:
    player.winInventory.close()

proc openAssembler*(player: Player) =
  if player.winAssembler.isNil:
    let win = wm.newUserWindow(64, 64, 256, 384, L"win.assembler title")
    win.onClose = proc (): bool =
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
  winToolbox = wm.newDockWindow(12, 12, 32, 60)
  updateToolboxPos(win.width.float, win.height.float)
  win.onResize do (width, height: Natural):
    updateToolboxPos(width.float, height.float)
  wm.add(winToolbox)

  var inventoryButton = newButton(4, 4, 24, 24, ButtonDock("inventory"))
  inventoryButton.onClick = proc () =
    player.openInventory()

  var assemblerButton = newButton(4, 32, 24, 24, ButtonDock("assembler"))
  assemblerButton.onClick = proc () =
    player.openAssembler()

  winToolbox.add(inventoryButton)
  winToolbox.add(assemblerButton)
