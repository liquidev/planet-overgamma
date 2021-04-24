## The core module.

import std/os
import std/tables

import game_registry
import items
import logger
import module
import resources
import tiles

import core/worldgen_canon

proc loadCore*(m: var Module, g: Game, r: GameRegistry) =
  ## Loads the core module.

  info "loading core module"

  m = newModule(g, r, "Core", rootPath = "data/core")

  hint "core: items"

  template item(variable: untyped, name: string) =
    let
      filename = addFileExt("items"/`name`, "png")
      sprite = m.loadSprite(filename)
      `variable` {.inject.} = m.registerItem(`name`, initItem(sprite))

  item iPlantMatter, "plant_matter"
  item iStone, "stone"

  hint "core: blocks"

  type
    BlockKind = enum
      Single
      Patch

  const
    blocks = {
      "plants":      (kind: Patch, solid: true, hardness: 1.5),
      "rock":        (kind: Patch, solid: true, hardness: 2.0),
#       "bricks":      (kind: Patch, solid: true, hardness: 2.0),
#       "light_metal": (kind: Patch, solid: true, hardness: 2.5),
#       "heavy_metal": (kind: Patch, solid: true, hardness: 3.0),
    }
  let
    blockDrops = {
      "plants": @[iPlantMatter.drop(1_0)],
      "rock": @[iStone.drop(1_0)]
    }.toTable

  for (name, data) in blocks:
    let
      (kind, solid, hardness) = data
      drops = blockDrops[name]
      filename = addFileExt("tiles"/name, "png")
    case kind
    of Single:
      let single = m.loadSingle(name, filename)
      discard m.registerBlock(name, initBlock(single, solid, hardness, drops))
    of Patch:
      let patch = m.loadBlockPatch(name, filename)
      discard m.registerBlock(name, initBlock(patch, solid, hardness, drops))

  hint "core: generation"

  discard m.registerWorldGenerator("canon", getCanonWorldGenerator())
