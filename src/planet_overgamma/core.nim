## The core module.

import std/os

import game_registry
import logger
import module
import resources
import tiles

import core/worldgen_canon

proc loadCore*(m: var Module, g: Game, r: GameRegistry) =
  ## Loads the core module.

  info "loading core module"

  m = newModule(g, r, "Core", rootPath = "data/core")

  hint "core: resources"

  type
    BlockKind = enum
      Single
      Patch

  const blocks = {
    "plants":      (kind: Patch,),
    "rock":        (kind: Patch,),
    "bricks":      (kind: Patch,),
    "light_metal": (kind: Patch,),
    "heavy_metal": (kind: Patch,),
  }

  for (name, data) in blocks:
    let
      (kind,) = data
      filename = addFileExt("tiles"/name, "png")
    case kind
    of Single:
      let single = m.loadSingle(name, filename)
      discard m.registerBlock(name, initBlock(single))
    of Patch:
      let patch = m.loadBlockPatch(name, filename)
      discard m.registerBlock(name, initBlock(patch))

  hint "core: generation"

  discard m.registerWorldGenerator("canon", getCanonWorldGenerator())
