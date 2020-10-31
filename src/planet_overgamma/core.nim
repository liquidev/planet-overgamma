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
    "plants":      (kind: Patch, solid: true),
    "rock":        (kind: Patch, solid: true),
    "bricks":      (kind: Patch, solid: true),
    "light_metal": (kind: Patch, solid: true),
    "heavy_metal": (kind: Patch, solid: true),
  }

  for (name, data) in blocks:
    let
      (kind, solid) = data
      filename = addFileExt("tiles"/name, "png")
    case kind
    of Single:
      let single = m.loadSingle(name, filename)
      discard m.registerBlock(name, initBlock(single, solid))
    of Patch:
      let patch = m.loadBlockPatch(name, filename)
      discard m.registerBlock(name, initBlock(patch, solid))

  hint "core: generation"

  discard m.registerWorldGenerator("canon", getCanonWorldGenerator())
