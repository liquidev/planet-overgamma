#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/world/aabb

type
  TileKind* = enum
    tkVoid
    tkBlock
    tkDecor
  Tile* = ref object
    solid*: bool
    case kind*: TileKind
    of tkVoid: discard
    of tkBlock:
      blockName*: string
    of tkDecor:
      decorName*: string
      decorVar*: int
    decor*: Tile

proc isSolid*(tile: Tile): bool =
  result = tile.solid

proc hitbox*(x, y: float, tile: Tile): RAABounds =
  result = newRAABB(x * 8, y * 8, 8, 8)

proc voidTile*(): Tile =
  result = Tile(solid: false, kind: tkVoid)

proc blockTile*(name: string, solid: bool): Tile =
  result = Tile(solid: solid, kind: tkBlock, blockName: name)

proc decorTile*(name: string, variation: int): Tile =
  result = Tile(kind: tkDecor, decorName: name, decorVar: variation)

proc `==`*(a, b: Tile): bool =
  result =
    if a.kind != b.kind or a.solid != b.solid: false
    elif a.kind == tkBlock:
      a.blockName == b.blockName
    else:
      false
