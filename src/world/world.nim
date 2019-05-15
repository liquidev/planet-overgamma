#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import random
import tables

import glm/noise
import rapid/gfx/surface
import rapid/world/tilemap

import ../debug
import ../res/resources
import tile
import worldconfig

proc drawWorld*(ctx: var RGfxContext, wld: RTmWorld[Tile], step: float) =
  ctx.texture = terrain
  ctx.begin()
  for x, y, t in tiles(wld):
    case t.kind
    of tkVoid: discard
    of tkBlock:
      let
        conn =
          (if wld[x + 1, y] == t: 0b0001 else: 0) or
          (if wld[x - 1, y] == t: 0b0010 else: 0) or
          (if wld[x, y + 1] == t: 0b0100 else: 0) or
          (if wld[x, y - 1] == t: 0b1000 else: 0)
        key = (t.blockName, conn)
      ctx.rect(x.float * 8, y.float * 8, 8, 8, terrainData.blocks[key])
    of tkFluid:
      discard # TODO: fluid rendering
  ctx.draw()
  ctx.noTexture()

proc newWorld*(width, height: Natural): RTmWorld[Tile] =
  result = newRTmWorld[Tile](width, height, 8, 8)
  result.implTile(tile.voidTile, tile.isSolid)
  result.drawImpl = drawWorld
  result.oobTile = voidTile()
  result.init()