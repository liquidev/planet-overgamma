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

  echo world[vec2i(0, -2)]
  echo world[vec2i(8, -2)]

  # const y = -2

  # world[vec2i(0, y)] = (emptyTile, blockTile(bRock))
  # world[vec2i(8, y)] = (emptyTile, blockTile(bRock))
  # world[vec2i(0, y - 8)] = (emptyTile, blockTile(bRock))
  # world[vec2i(8, y - 8)] = (emptyTile, blockTile(bRock))

  # for i in countdown(0, -32):
  #   let
  #     x = int32(-i)
  #     y1 = int32(i)
  #     y2 = int32(-i)
  #   world[vec2i(x, y1)] = (emptyTile, blockTile(bRock))
  #   world[vec2i(x, y2)] = (emptyTile, blockTile(bRock))

  # generate
  # MapTile tuple order: (background, foreground)
  world.fillRows(0, 32, (emptyTile, blockTile(bRock)))

  # echo world[vec2i(-2, -2)]

  for n in 1..10:
    let y = n.int32 * 2
    world[vec2i(0, -20 + y)] = (emptyTile, blockTile(bRock))
    world[vec2i(1, -20 + y)] = (emptyTile, blockTile(bRock))
    world[vec2i(2, -19 + y)] = (emptyTile, blockTile(bRock))
    world[vec2i(3, -19 + y)] = (emptyTile, blockTile(bRock))
    world[vec2i(10, -20 + y)] = (emptyTile, blockTile(bPlants))
    world[vec2i(10, -19 + y)] = (emptyTile, blockTile(bPlants))

  # echo world[vec2i(-2, -2)]

proc getCanonWorldGenerator*(): WorldGenerator =
  newWorldGenerator(
    params = {
      "width": sliderParam(pdtInt, 256.0..512.0),
    }.toTable,
    impl = canonGenerate
  )
