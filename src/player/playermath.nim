#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx

import ../res
import ../world/worldconfig
import playerdef

proc scrToWld*(plr: Player, pos: Vec2[float]): Vec2[float] =
  ## Converts screen coordinates into world coordinates.
  ## Used primarily for mouse input.
  result =
    (pos - vec2(sur.width / 2, sur.height / 2)) / WorldScale + plr.pos + 4
