#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import tables

import rapid/gfx
import rapid/gfx/text

import ../items/itemstorage
import ../player/playermath
import ../colors
import ../res
import control
import textbox

type
  StorageGrid* = ref object of Control
    storage*: ItemStorage
    cols*: int

method width*(grid: StorageGrid): float = grid.cols.float * 36

renderer(StorageGrid, Default, grid):
  var
    x, y = 0.0
  for n in 0..<5:
    var iter = grid.storage.iterate()
    for id, amt in iter():
      ctx.clearStencil(0)
      ctx.stencil(saReplace, 255):
        ctx.begin(); ctx.rect(x, y, 37, 37); ctx.draw()
      ctx.stencil(saReplace, 0):
        ctx.begin(); ctx.rect(x + 1, y + 1, 35, 35); ctx.draw()
      ctx.stencilTest = (scEq, 255)
      ctx.color = col"ui.containerGrid.item.border"
      ctx.begin(); ctx.rect(x, y, 37, 37); ctx.draw()
      ctx.color = col"base.white"
      ctx.noStencilTest()

      ctx.begin()
      ctx.texture = itemSprites
      ctx.rect(x + 4, y + 1, 28, 28, itemSpriteData[id])
      ctx.draw()
      ctx.noTexture()

      firaSans.height = 10
      ctx.text(firaSans, x, y, amt.itemAmtStr, 36, 34, taCenter, taBottom)
      firaSans.height = 14
      x += 36
      if x >= grid.cols.float * 32:
        y += 36
        x = 0

proc initStorageGrid*(grid: StorageGrid, x, y: float, storage: ItemStorage,
                      cols: int, rend = StorageGridDefault) =
  grid.initControl(x, y, rend)
  grid.storage = storage
  grid.cols = cols

proc newStorageGrid*(x, y: float, storage: ItemStorage, cols: int,
                     rend = StorageGridDefault): StorageGrid =
  new(result)
  result.initStorageGrid(x, y, storage, cols, rend)

type
  StorageView* = ref object of Control
    search: TextBox
    grid: StorageGrid
