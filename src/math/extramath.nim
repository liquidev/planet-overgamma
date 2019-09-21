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

proc cclamp*[T](x, a, b: T): T =
  ## Comparison clamp. Uses an if statement rather than min and max.
  ## ``a`` must always be the lower bound.
  if x < a: a
  elif x > b: b
  else: x
