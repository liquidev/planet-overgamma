#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import tables

import rapid/gfx
import rapid/gfx/text
import rapid/res/fonts

import ../items/container
import control

import ../player/playermath
import ../colors
import ../res

type
  ContainerGrid* = ref object of Control
    container*: Container
    cols*: int
  ContainerView* = ref object of Control
    grid: ContainerGrid

renderer(ContainerGrid, Default, grid):
  var x, y = 0.0
  for id, amt in grid.container:
    ctx.clearStencil(0)
    ctx.stencil(saReplace, 255):
      ctx.begin(); ctx.rect(x, y, 33, 33); ctx.draw()
    ctx.stencil(saReplace, 0):
      ctx.begin(); ctx.rect(x + 1, y + 1, 31, 31); ctx.draw()
    ctx.stencilTest = (scEq, 255)
    ctx.color = col.ui.containerGrid.item.border
    ctx.begin(); ctx.rect(x, y, 33, 33); ctx.draw()
    ctx.color = col.base.white
    ctx.noStencilTest()

    ctx.begin()
    ctx.texture = itemSprites
    ctx.rect(x + 4, y + 1, 24, 24, itemSpriteData[id])
    ctx.draw()
    ctx.noTexture()

    firaSans.height = 9
    ctx.text(firaSans, x + 2, y + 30 - 9, amt.itemAmtStr)
    firaSans.height = 14
    x += 32
    if x >= grid.cols.float * 32:
      y += 32
      x = 0

proc initContainerGrid*(grid: ContainerGrid, x, y: float, container: Container,
                        cols: int, rend = ContainerGridDefault) =
  grid.initControl(x, y, rend)
  grid.container = container
  grid.cols = cols

proc newContainerGrid*(x, y: float, container: Container, cols: int,
                       rend = ContainerGridDefault): ContainerGrid =
  new(result)
  result.initContainerGrid(x, y, container, cols, rend)
