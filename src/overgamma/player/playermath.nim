#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import math
import strutils

import rapid/gfx

import ../world/worldconfig
import ../res
import playerdef

proc scrToWld*(plr: Player, pos: Vec2[float]): Vec2[float] =
  ## Converts screen coordinates into world coordinates.
  ## Used primarily for mouse input.
  result =
    (pos - vec2(sur.width / 2, sur.height / 2)) / WorldScale + plr.pos + 4

proc format(x: float, prec: range[-1..32]): string =
  result =
    if x.trunc == x: $x.int
    else: x.formatFloat(ffDecimal, prec)

proc itemAmtStr*(amt: float): string =
  ## Converts an item amount to a string.
  result =
    if   amt <           100: amt.format(2)
    elif amt <         1_000: amt.format(1)
    elif amt <        10_000: format(amt / 1_000, 2) & 'k'
    elif amt <     1_000_000: format(amt / 1_000, 1) & 'k'
    elif amt <   100_000_000: format(amt / 1_000_000, 1) & 'M'
    elif amt < 1_000_000_000: $int(amt / 1_000_000) & 'M'
    else: "B"
