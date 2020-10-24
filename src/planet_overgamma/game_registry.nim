## Master object holding all the smaller registries.

import tiles
import world_generation

type
  GameRegistry* = ref object
    ## Registry for all game data.

    blockRegistry*: BlockRegistry
    worldGenRegistry*: WorldGeneratorRegistry
