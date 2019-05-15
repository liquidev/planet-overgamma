#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import random

import glm/noise
import rapid/world/tilemap

import ../debug
import tile
import world
import worldconfig

proc generateOverworld*(wld: var RTmWorld[Tile], seed: int64) =
  wld = newWorld(WorldWidth, WorldHeight)

  var rng = initRand(seed)

  verbose("World gen", "generating height map")
  var heightMap: seq[int]
  block genHeightMap:
    let
      xo = rng.rand(10000000000.0)
      yo = rng.rand(10000000000.0)
    for x in 0..<wld.width:
      heightMap.add(int(
        16 + simplex(vec2(xo + cos(x / 10), yo + cos(x / 10))) * 8))

  verbose("World gen", "filling blocks using height map")
  block fillHeightMap:
    for x in 0..<wld.width:
      for y in heightMap[x]..<wld.height:
        wld[x, y] = blockTile("plants", solid = true)
