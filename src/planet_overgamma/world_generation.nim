## Utilities related to world generation.

import glm/vec

import game_registry
import parameters
import resources
import world
import world_generation_base

export world_generation_base

type
  GenerateWorldImpl = proc (world: var World, r: GameRegistry, args: Arguments)
    ## Callback for world generation. The callback must set ``world`` to a new
    ## world. An error is raised if the resulting world is nil.

  WorldGenerator* = ref object of BaseWorldGenerator
    generateImpl: GenerateWorldImpl

  WorldGenerationError* = object of ValueError

proc generate*(gen: WorldGenerator, g: Game, r: GameRegistry,
               args: Arguments): World =
  ## Generates a new world using the given generator, passing the given
  ## arguments to it.

  gen.generateImpl(result, r, args)
  if result == nil:
    raise newException(WorldGenerationError,
                       "the world generator returned a nil world")
  result.updateChunks(g)

proc newWorldGenerator*(params: Parameters,
                        impl: GenerateWorldImpl): WorldGenerator =
  ## Creates a new world generator with the given parameters and
  ## generate world callback.
  WorldGenerator(parameters: params, generateImpl: impl)

iterator columns*(world: World): int32 =
  ## Iterates over all the x coordinates in the world, ie. ``0..world.width``.
  ##
  ## Note that there is no `rows` equivalent. That's because the world is only
  ## finite (and looping) on the X axis. On the Y axis however, the world is
  ## infinitely large, so there is no minimum or maximum height that can be
  ## reached.

  for x in 0..world.width:
    yield x

proc fillRows*(world: World, y1, y2: int32, tile: MapTile) =
  ## Fills all rows in the range ``y1..y2`` with a single ``tile``.

  for y in y1..y2:
    for x in world.columns:
      world[vec2i(x, y)] = tile
