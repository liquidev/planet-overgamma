import json

{.push experimental: "dotOperators".}

template `.`*(node: JsonNode, field: untyped): JsonNode =
  node[astToStr(field)]

{.pop.}
