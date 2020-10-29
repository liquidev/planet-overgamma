## "Canon" world generator – the official one.™

import std/tables

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

  # initialize
  world = newWorld(width)

  # generate
  # MapTile tuple order: (background, foreground)
  world.fillRows(8, 32, (emptyTile, blockTile(bPlants)))

proc getCanonWorldGenerator*(): WorldGenerator =
  newWorldGenerator(
    params = {
      "width": sliderParam(pdtInt, 256.0..512.0),
    }.toTable,
    impl = canonGenerate
  )
