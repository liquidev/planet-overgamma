#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import tables

import rapid/gfx
import rapid/world/sprite

import ../world/worldconfig
import ../res

type
  Item* = ref object of RSprite
    id*: string
    count*: float

method draw*(item: Item, ctx: RGfxContext, step: float) =
  # Items are always drawn in batches
  ctx.rect(item.pos.x - 1, item.pos.y - 1, 8, 8, itemSpriteData[item.id])

method update*(item: Item, step: float) =
  item.force(Gravity * 0.5)
  item.vel.x *= 0.9
  if item.count <= 0:
    item.delete = true

proc newItem*(x, y: float, id: string, count = 1.0): Item =
  result = Item(
    width: 6, height: 6,
    pos: vec2(x, y),
    id: id, count: count
  )
