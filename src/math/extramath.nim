#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import math

import glm/vec

proc distance*(a, b: Vec2[float]): float =
  let
    dx = b.x - a.x
    dy = b.y - a.y
  result = sqrt(dx * dx + dy * dy)
