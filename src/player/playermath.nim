#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import glm

import ../res/resources
import ../world/worldconfig
import playerdef

proc wldToScr*(plr: Player, pos: Vec2[float]): Vec2[float] =
  result = pos - plr.pos

proc scrToWld*(plr: Player, pos: Vec2[float]): Vec2[float] =
  result = (pos - vec2(gfx.width / 2, gfx.height / 2)) / WorldScale + plr.pos + 4
