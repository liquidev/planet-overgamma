#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import json
import options
import tables

import rapid/gfx/texpack

import ../debug

type
  ItemDropKind* = enum
    idFixed
    idRange
  ItemDrop* = object
    item*: string
    case kind: ItemDropKind
    of idFixed: amount*: float
    of idRange: min*, max*: float

  TileDesc* = object
    name*, uiName*: string
    hardness*: float
    drops*: seq[ItemDrop]

  TileDatabase* = ref object
    blocks*, decor*: Table[string, TileDesc]

proc kind*(td: ItemDrop): ItemDropKind = td.kind

proc newTileDatabase*(): TileDatabase =
  ## Creates a new tile database.
  new(result)

proc newTileDesc*(name, uiName: string,
                  hardness = 1.0, drops: seq[ItemDrop] = @[]): TileDesc =
  result.name = name
  result.hardness = hardness
  result.drops = drops

proc dropOne*(item: string): ItemDrop =
  result = ItemDrop(item: item, kind: idFixed, amount: 1.0)

proc dropAmount*(item: string, amount: float): ItemDrop =
  result = ItemDrop(item: item, kind: idFixed, amount: amount)

proc dropMinMax*(item: string, min, max: float): ItemDrop =
  result = ItemDrop(item: item, kind: idRange, min: min, max: max)

