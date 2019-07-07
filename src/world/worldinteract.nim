#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import options
import random
import tables

import glm
import rapid/world/sprite

import ../items/worlditem
import ../res
import tile
import tiledb
import world

proc drop*(world: World, x, y: float, drop: openarray[ItemDrop]) =
  for it in drop:
    let amount =
      if it.min.isSome: rand(it.min.get..it.max.get)
      else: it.amt.get(1.0)
    var item = newItem(x, y, it.item, amount)
    item.force(vec2(rand(-1.5..1.5), rand(-1.0..1.0)))
    world.add(item)

proc destroy*(world: World, x, y: int, power: float): float

proc update*(world: World, x, y: int) =
  let tile = world[x, y]
  case tile.kind
  of tkDecor:
    if not world[x, y + 1].isSolid:
      discard world.destroy(x, y, Inf)
  else: discard

proc destroy*(world: World, x, y: int, power: float): float =
  let tile = world[x, y]
  let
    entry =
      case tile.kind
      of tkBlock: tiles.blocks[tile.blockName]
      of tkDecor: tiles.decor[tile.decorName]
      of tkVoid: default(Entry)
    hardness =
      case tile.kind
      of tkVoid: Inf
      else: entry.hardness.get(1.0)
  if power >= hardness:
    let drop =
      case tile.kind
      of tkVoid: @[]
      else: entry.drops.get(@[])
    world[x, y] = voidTile()
    world.drop(x.float * 8, y.float * 8, drop)
    world.update(x - 1, y)
    world.update(x + 1, y)
    world.update(x, y - 1)
    world.update(x, y + 1)
    result = hardness
