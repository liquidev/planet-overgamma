## Utilities related to world generation.

import parameters
import registry
import world

type
  GenerateWorldCallback* = proc (world: World, args: Arguments)

  WorldGenerator* = object
    parameters*: Parameters
    generateImpl: GenerateWorldCallback

  WorldGeneratorRegistry* = Registry[WorldGenerator]

proc initWorldGenerator*(parameters: Parameters,
                         generateImpl: GenerateWorldCallback): WorldGenerator =
  ## Creates and initializes a new world generator.
  WorldGenerator(parameters: parameters, generateImpl: generateImpl)

proc generate*(gen: WorldGenerator, args: Arguments): World =
  ## Generates a new world with the given arguments.

  result = newWorld()
  gen.generateImpl(result, args)
