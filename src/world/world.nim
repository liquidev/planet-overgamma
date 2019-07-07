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
import rapid/gfx
import rapid/gfx/fxsurface
import rapid/res/textures
import rapid/world/sprite
import rapid/world/tilemap

import ../items/worlditem
import ../debug
import ../res
import tile
import worldconfig

export tilemap

type
  World* = RTmWorld[Tile]

var items: seq[Item]

proc drawWorld*(ctx: RGfxContext, wld: World, step: float) =
  if settings.graphics.pixelate:
    fx.begin(ctx)
  transform(ctx):
    # camera
    let plr = wld["player"]
    ctx.translate(sur.width / 2, sur.height / 2)
    ctx.scale(WorldScale, WorldScale)
    ctx.translate(-plr.pos.x - 4, -plr.pos.y - 4)

    # viewport
    let
      (plrx, plry) = wld.tilePos(plr.pos.x + 4, plr.pos.y + 4)
      (ww, wh) = wld.tilePos(sur.width.float / WorldScale,
                             sur.height.float / WorldScale)
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
    ctx.draw()
    ctx.noTexture()
    items.setLen(0)
    for spr in wld:
      if not (spr of Item):
        spr.draw(ctx, step)
      else:
        items.add(spr.Item)
    ctx.begin()
    ctx.texture = itemSprites
    for it in items:
      it.draw(ctx, step)
    ctx.draw()
  if settings.graphics.pixelate:
    fxQuantize.param("scale", WorldScale.float)
    fx.effect(fxQuantize)
    fx.finish()

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
