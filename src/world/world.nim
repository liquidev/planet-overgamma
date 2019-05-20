#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import math
import random
import tables

import glm/noise
import rapid/gfx/surface
import rapid/res/textures
import rapid/world/tilemap

import ../debug
import ../res/resources
import ../player/playerbase
import tile
import worldconfig

proc drawWorld*(ctx: var RGfxContext, wld: RTmWorld[Tile], step: float) =
  transform(ctx):

    # camera
    let plr = wld["player"]
    ctx.translate(ctx.gfx.width / 2, ctx.gfx.height / 2)
    ctx.scale(WorldScale, WorldScale)
    ctx.translate(-plr.pos.x - 4, -plr.pos.y - 4)

    # viewport
    let
      (plrx, plry) = wld.tilePos(plr.pos.x, plr.pos.y)
      (ww, wh) = wld.tilePos(gfx.width.float, gfx.height.float)
      vptop = plry - int(wh / 2)
      vpleft = plrx - int(ww / 2)
      vpbottom = plry + int(wh / 2)
      vpright = plrx + int(ww / 2)

    ctx.texture = terrain
    ctx.begin()
    for x, y, t in areab(wld, vptop, vpleft, vpbottom, vpright):
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
        ctx.rect(floor(x.float * 8), floor(y.float * 8), 8, 8,
                 terrainData.blocks[key])
      of tkFluid:
        discard # TODO: fluid rendering
    ctx.draw()
    ctx.noTexture()
    wld.drawSprites(ctx, step)

proc newWorld*(width, height: Natural): RTmWorld[Tile] =
  result = newRTmWorld[Tile](width, height, 8, 8)
  result.implTile(tile.voidTile, tile.isSolid)
  result.drawImpl = drawWorld
  result.oobTile = voidTile()
  result.wrapX = true
  result.init()
