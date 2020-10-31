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
    # parameters
    width = args["width"].intValue
    # block IDs
    bPlants = r.blockRegistry.id("Core::plants")
    bRock = r.blockRegistry.id("Core::rock")

  # initialize
  world = newWorld(width)

  # generate
  # MapTile tuple order: (background, foreground)
  world.fillRows(0, 32, (emptyTile, blockTile(bRock)))

  for n in 1..10:
    let y = n.int32 * 2
    world[vec2i(0, -20 + y)] = (emptyTile, blockTile(bRock))
    world[vec2i(1, -20 + y)] = (emptyTile, blockTile(bRock))
    world[vec2i(2, -19 + y)] = (emptyTile, blockTile(bRock))
    world[vec2i(3, -19 + y)] = (emptyTile, blockTile(bRock))
    world[vec2i(10, -20 + y)] = (emptyTile, blockTile(bPlants))
    world[vec2i(10, -19 + y)] = (emptyTile, blockTile(bPlants))

  echo world[vec2i(-2, 0)]

proc getCanonWorldGenerator*(): WorldGenerator =
  newWorldGenerator(
    params = {
      "width": sliderParam(pdtInt, 256.0..512.0),
    }.toTable,
    impl = canonGenerate
  )
