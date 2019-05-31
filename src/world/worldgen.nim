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

proc generateOverworld*(wld: var World, seed: int64) =
  wld = newWorld(WorldWidth, WorldHeight)

  var rng = initRand(seed)
  let
    # offsets for Perlin Noise
    xo = rng.rand(10000000000.0)
    yo = rng.rand(10000000000.0)

  verbose("World gen", "generating height map")
  var heightMap = newSeq[float](wld.width)

  template hmGet(x: int): float =
    heightMap[int(floorMod(x.float, wld.width.float))]
  template hmSet(x: int, y: float) =
    heightMap[int(floorMod(x.float, wld.width.float))] = y

  block genHeightMap:
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
    for x, y, t in tiles(wld):
      const
        Blur = boxBlur(9)
      let
        normalY = hmGet(x)
        blurredY = heightMap.conv(x, Blur)
      # plants
      if y.float >= normalY:
        wld[x, y] = blockTile("plants", solid = true)
      # stone
      if y.float >= blurredY + 16:
        wld[x, y] = blockTile("stone", solid = true)

  verbose("World gen", "spawn player")
  block spawnPlayer:
    var player = newPlayer(DefaultPlayerName)
    let x = rng.rand(wld.width - 1)
    player.pos = vec2(x.float * 8, float(wld.highestY(x)) * 8)
    wld.add("player", player)

  verbose("World gen", "decorating the world")
  block decorate:
    for x in 0..<wld.width:
      let
        angle = x / wld.width * (6 * Pi)
        noise = (perlin(vec3(xo + cos(angle), yo + sin(angle), 1.0)) + 1) / 2
        y = wld.highestY(x)
      if rng.rand(1.0) > noise:
        wld[x, y] = decorTile("grass", rng.rand(0..2))
      if rng.rand(1.0) < 0.15:
        wld[x, y] = decorTile("pebbles", rng.rand(0..2))

  verbose("World gen", "finished")
