import math
import tables

import rapid/gfx
import rapid/gfx/text
import rdgui/control
import rdgui/event

import ../items/itemstorage
import ../player/playermath
import ../util/fuzzy
import ../colors
import ../res
import ../lang
import textbox

type
  StorageGrid* = ref object of Control
    storage*: ItemStorage
    cols*: int
    searchResults: OrderedTable[string, float]

const
  StorageGridRepeat {.intdefine.} = 1

method width*(grid: StorageGrid): float = grid.cols.float * 36
method height*(grid: StorageGrid): float =
  ceil(grid.storage.len * StorageGridRepeat / grid.cols) * 36

proc search*(grid: StorageGrid, phrase: string) =
  grid.searchResults.clear()
  var iter = grid.storage.iterate()
  for id, amt in iter():
    if phrase == "" or L("items " & id) ==* phrase:
      grid.searchResults.add(id, amt)

renderer(StorageGrid, Default, grid):
  var x, y = 0.0
  for n in 0..<StorageGridRepeat:
    for id, amt in grid.searchResults:
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
      ctx.texture = sheet".items".texture
      ctx.rect(x + 4, y + 1, 28, 28, sheet".items"[id][0])
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
  grid.search("")

proc newStorageGrid*(x, y: float, storage: ItemStorage, cols: int,
                     rend = StorageGridDefault): StorageGrid =
  new(result)
  result.initStorageGrid(x, y, storage, cols, rend)

type
  StorageView* = ref object of Control
    search: TextBox
    grid: StorageGrid

proc search*(view: StorageView): TextBox = view.search
proc grid*(view: StorageView): StorageGrid = view.grid

method onEvent*(view: StorageView, ev: UIEvent) =
  view.search.event(ev)
  view.grid.event(ev)

renderer(StorageView, Default, view):
  view.search.draw(ctx, step)
  view.grid.draw(ctx, step)

proc initStorageView*(view: StorageView, x, y: float, storage: ItemStorage,
                      cols: int, rend = StorageViewDefault) =
  view.initControl(x, y, rend)
  view.onContain do:
    view.search = newTextBox(0, 0, 0, "Search…")
    view.grid = newStorageGrid(0, view.search.height + 8, storage, cols)

    view.search.width = view.grid.width
    view.search.onInput = proc () =
      view.grid.search(view.search.text)

    view.contain(view.search)
    view.contain(view.grid)

proc newStorageView*(x, y: float, storage: ItemStorage, cols: int,
                     rend = StorageViewDefault): StorageView =
  result = StorageView()
  result.initStorageView(x, y, storage, cols, rend)
