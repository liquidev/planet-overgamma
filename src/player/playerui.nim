#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx

import ../gui
import ../gui/[control, button]
import ../gui/windows
import playerdef

proc openInventory*(player: Player) =
  if player.winInventory.isNil:
    player.winInventory = wm.newWindow(64, 64, 192, 256, "Inventory",
                          wkDecorated)
    wm.add(player.winInventory)
  else:
    player.winInventory.close()
    player.winInventory = nil

proc initPlayerUI*(player: Player) =
  var inventoryButton = newButton(4, 4, 24, 24, "inventory", ButtonDock)
  inventoryButton.onClick = proc (btn: Button) =
    player.openInventory()
  winToolbox.add(inventoryButton)
