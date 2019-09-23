#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import json
import options
import tables

import ../debug

type
  ItemDrop* = object
    item*: string
    amt*, min*, max*: Option[float]

  Entry* = object
    hardness*: Option[float]
    drops*: Option[seq[ItemDrop]]

  TileDatabase* = ref object
    blocks*, decor*: Table[string, Entry]

proc loadTileDatabase*(file: string): TileDatabase =
  info("Loading", "tile database from ", file)
  let obj = json.parseFile(file)
  result = obj.to(TileDatabase)
  verbose("TileDb", "finished")
