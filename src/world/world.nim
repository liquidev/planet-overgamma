#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import math
import random
import strutils
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

type
  World* = RTmWorld[Tile]

proc drawWorld*(ctx: var RGfxContext, wld: World, step: float) =
  effects(ctx):
    transform(ctx):
      # camera
      let plr = wld["player"]
      ctx.translate(gfx.width / 2, gfx.height / 2)
      ctx.scale(WorldScale, WorldScale)
      ctx.translate(-plr.pos.x - 4, -plr.pos.y - 4)

      # viewport
      let
        (plrx, plry) = wld.tilePos(plr.pos.x + 4, plr.pos.y + 4)
        (ww, wh) = wld.tilePos(gfx.width.float / WorldScale,
                              gfx.height.float / WorldScale)
        vptop = plry - int(wh / 2) - 1
        vpleft = plrx - int(ww / 2) - 1
        vpbottom = plry + int(wh / 2) + 1
        vpright = plrx + int(ww / 2) + 1

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
        of tkDecor:
          let key = (t.decorName, t.decorVar)
          ctx.rect(floor(x.float * 8), floor(y.float * 8), 8, 8,
                  terrainData.decor[key])
        of tkFluid:
          discard # TODO: fluids
      ctx.draw()
      ctx.noTexture()
      wld.drawSprites(ctx, step)
    fxQuantize.param("scale", WorldScale.float)
    ctx.effect(fxQuantize)

proc highestY*(wld: World, x: int): int =
  for y in 0..<wld.height:
    if wld[x, y].kind == tkVoid:
      result = y
    else:
      return

proc newWorld*(width, height: Natural): World =
  result = newRTmWorld[Tile](width, height, 8, 8)
  result.implTile(tile.voidTile, tile.isSolid)
  result.drawImpl = drawWorld
  result.oobTile = voidTile()
  result.wrapX = true
  result.init()
