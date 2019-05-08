#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) iLiquid, 2018-2019
#--

type
  TileKind* = enum
    tkBlock
  Tile* = ref object
    solid*: bool
    case kind*: TileKind
    of tkBlock:
      blockName*: string
