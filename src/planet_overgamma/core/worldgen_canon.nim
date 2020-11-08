## "Canon" world generator – the official one.™

import std/tables

import glm/vec

import ../game_registry
import ../parameters
import ../tiles
import ../world
import ../world_generation

proc canonGenerate(world: var World, r: GameRegistry, args: Arguments) =

  let
    # aliases
    br = r.blockRegistry
    # parameters
    width = args["width"].intValue
    # block IDs
    bPlants = br.id("Core::plants")
    bRock = br.id("Core::rock")

  # initialize
  world = r.newWorld(width)

  # generate
  # MapTile tuple order: (background, foreground)
  world.fillRows(0, 32, (emptyTile, br.blockTile(bPlants)))

  for x in 3..10:
    for y in -x .. 0:
      world[vec2i(x.int32, y.int32)] = (emptyTile, br.blockTile(bRock))

  world[vec2i(0, -1)] = (emptyTile, br.blockTile(bRock))

  world.playerSpawnPoint = vec2f(6, -20)

proc getCanonWorldGenerator*(): WorldGenerator =
  newWorldGenerator(
    params = {
      "width": sliderParam(pdtInt, 256.0..512.0),
    }.toTable,
    impl = canonGenerate
  )
