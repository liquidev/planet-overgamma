#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import json

{.push experimental: "dotOperators".}

template `.`*(node: JsonNode, field: untyped): JsonNode =
  node[astToStr(field)]

{.pop.}
