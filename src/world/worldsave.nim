#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/world/tilemap

import ../debug
import tile
import worldgen

type
  WorldSave* = ref object
    overworld*: RTmWorld[Tile]
    underground*: RTmWorld[Tile]

var currentSave*: WorldSave

proc newSave*(seed: int64): WorldSave =
  info("Save", "creating new save using seed ", seed)
  result = WorldSave()
  generateOverworld(result.overworld, seed)
