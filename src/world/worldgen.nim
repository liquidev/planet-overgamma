#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import random

import glm/noise
import rapid/world/tilemap

import ../math/kernel
import ../player/playerbase
import ../debug
import tile
import world
import worldconfig


proc generateOverworld*(wld: var RTmWorld[Tile], seed: int64) =
  wld = newWorld(WorldWidth, WorldHeight)

  var rng = initRand(seed)

  verbose("World gen", "generating height map")
  var heightMap = newSeq[float](wld.width)

  template hmGet(x: int): float =
    heightMap[int(floorMod(x.float, wld.width.float))]
  template hmSet(x: int, y: float) =
    heightMap[int(floorMod(x.float, wld.width.float))] = y

  block genHeightMap:
    let
      xo = rng.rand(10000000000.0)
      yo = rng.rand(10000000000.0)
    echo xo, " ", yo
    for x in 0..<wld.width:
      let
        angle = x / wld.width * (6 * Pi)
        y = 16 + (
          perlin(vec3(xo + cos(angle), yo + sin(angle), 0.0)) +
          perlin(vec3(xo + cos(angle), yo + sin(angle),
            perlin(vec2(xo + cos(angle), yo + sin(angle)))))
        ) * 8
      hmSet(x, y)

  verbose("World gen", "filling blocks using height map")
  block fillHeightMap:
    for x in 0..<wld.width:
      for y in 0..<wld.height:
        const
          Blur = boxBlur(9)
        let
          normalY = hmGet(x)
          blurredY = heightMap.conv(x, Blur)
        # plants
        if y.float >= normalY:
          wld[x, y] = blockTile("plants", solid = true)
        # rock
        if y.float >= blurredY + 16:
          wld[x, y] = blockTile("stone", solid = true)

  verbose("World gen", "spawn player")
  block spawnPlayer:
    var player = newPlayer(DefaultPlayerName)
    player.pos = vec2(32.0, 32.0)
    wld.add("player", player)
