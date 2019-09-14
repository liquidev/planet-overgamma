#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import json
import os
import strutils
import tables

import rapid/gfx

import debug
import res

var
  colorNode: JsonNode
  colorCache: Table[string, RColor]

proc walk(json: JsonNode, path: string): JsonNode =
  result = json
  var
    pos = 0
    ident = ""
  while pos < path.len:
    if path[pos] != '.':
      ident.add(path[pos])
    else:
      result = result[ident]
      ident = ""
    inc(pos)
  result = result[ident]

proc parseColor(col: string): RColor =
  case col[0]
  of '#':
    if col.len == 7:
      let
        red = parseHexInt(col[1..2])
        green = parseHexInt(col[3..4])
        blue = parseHexInt(col[5..6])
      result = rgb(red, green, blue)
    elif col.len == 9:
      let
        alpha = parseHexInt(col[1..2])
        red = parseHexInt(col[3..4])
        green = parseHexInt(col[5..6])
        blue = parseHexInt(col[7..8])
      result = rgba(red, green, blue, alpha)
    elif col.len == 4:
      let
        red = parseHexInt(col[1] & col[1])
        green = parseHexInt(col[2] & col[2])
        blue = parseHexInt(col[3] & col[3])
      result = rgb(red, green, blue)
    elif col.len == 5:
      let
        alpha = parseHexInt(col[1] & col[1])
        red = parseHexInt(col[2] & col[2])
        green = parseHexInt(col[3] & col[3])
        blue = parseHexInt(col[4] & col[4])
      result = rgba(red, green, blue, alpha)
    else:
      doAssert false,
        "Invalid hex color (must be #rgb, #argb, #rrggbb, or #aarrggbb)"
  else:
    result = parseColor(colorNode.walk(col).getStr("#f0f"))

proc col*(path: string): RColor =
  if path notin colorCache:
    colorCache.add(path, parseColor(path))
  result = colorCache[path]

proc loadColors*() =
  info("Loading", "colors")
  colorNode = json.parseFile(Data/"colors.json")
  verbose("Colors", "finished")
