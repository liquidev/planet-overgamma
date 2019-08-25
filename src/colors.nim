#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import json
import os
import strutils

import rapid/gfx

import util/jsondots
import debug
import res

export jsondots

var col*: JsonNode

converter toRColor*(node: JsonNode): RColor

proc parseColor(cols: string): RColor =
  case cols[0]
  of '#':
    if cols.len == 7:
      let
        red = parseHexInt(cols[1..2])
        green = parseHexInt(cols[3..4])
        blue = parseHexInt(cols[5..6])
      result = rgb(red, green, blue)
    elif cols.len == 9:
      let
        alpha = parseHexInt(cols[1..2])
        red = parseHexInt(cols[3..4])
        green = parseHexInt(cols[5..6])
        blue = parseHexInt(cols[7..8])
      result = rgba(red, green, blue, alpha)
    elif cols.len == 4:
      let
        red = parseHexInt(cols[1] & cols[1])
        green = parseHexInt(cols[2] & cols[2])
        blue = parseHexInt(cols[3] & cols[3])
      result = rgb(red, green, blue)
    elif cols.len == 5:
      let
        alpha = parseHexInt(cols[1] & cols[1])
        red = parseHexInt(cols[2] & cols[2])
        green = parseHexInt(cols[3] & cols[3])
        blue = parseHexInt(cols[4] & cols[4])
      result = rgba(red, green, blue, alpha)
    else:
      doAssert false,
        "Invalid hex color (must be #rgb, #argb, #rrggbb, or #aarrggbb"
  of '_':
    result = col.base[cols[1..^1]]
  else:
    doAssert false, "Invalid color string (must begin with '#' or '_')"

converter toRColor*(node: JsonNode): RColor =
  doAssert node.kind != JNull, "Color cannot be null"
  doAssert node.kind != JBool, "Color cannot be a boolean"
  result =
    case node.kind
    of JInt: gray(node.num)
    of JFloat: gray(int(node.fnum * 255))
    of JString: parseColor(node.str)
    else: gray(0)

proc loadColors*() =
  info("Loading", "colors")
  col = json.parseFile(Data/"colors.json")
  verbose("Colors", "finished")
