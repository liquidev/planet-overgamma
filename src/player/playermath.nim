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

proc itemAmtStr*(amt: float): string =
  ## Converts an item amount to a string. If the item amount is a whole number,
  ## outputs an integer. Otherwise, outputs a float with 2 decimal places.
  result =
    if amt.trunc == amt: $amt.int
    else: formatFloat(amt, ffDecimal, 2)
