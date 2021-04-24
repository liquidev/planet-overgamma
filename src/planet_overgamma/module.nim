## Modules, aka mods. They allow for easily extending the game in an organized
## manner.
##
## Ruby API coming soon.

import std/os
import std/strutils

import aglet/rect
import rapid/graphics
import rapid/graphics/image

import game_registry
import items
import logger
import registry
import resources
import tileset
import tiles
import world_generation

type
  Module* = ref object
    g*: Game
    r*: GameRegistry
    name*: string
    rootPath*: string

proc newModule*(g: Game, r: GameRegistry, name, rootPath: string): Module =
  ## Creates a new game module.

  new result
  result.g = g
  result.r = r
  result.name = name
  result.rootPath = rootPath


# namespaces and paths

proc namespaced*(m: Module, name: string): string =
  ## Returns the given name with a namespace prefix.
  ## Resources should be named using snake_case.
  m.name & "::" & name

proc getModuleName*(name: string): string =
  ## Returns the module name from the given qualified name.
  name.split("::", 1)[0]

proc resourcePath*(m: Module, path: string): string =
  ## Returns the file path for the given resource.
  m.rootPath / path


# game: master tileset

proc loadSprite*(m: Module, filename: string): Sprite =
  ## Loads a sprite into the game's graphics context. The filename is relative
  ## to the module's root directory.
  m.g.graphics.addSprite(loadImage(m.resourcePath(filename)))

proc loadSingle*(m: Module, name, filename: string): Rectf =
  ## Loads a single into the master tileset. The given name is namespaced
  ## automatically, and the path is relative to the module's root.
  m.g.masterTileset.loadSingle(m.namespaced(name), m.resourcePath(filename))

proc loadBlockPatch*(m: Module, name, filename: string): BlockPatch =
  ## Loads a block patch into the master tileset. The given name is namespaced
  ## automatically, and the path is relative to the module's root.
  m.g.masterTileset.loadBlockPatch(m.namespaced(name), m.resourcePath(filename))

proc blockPatch*(m: Module, name: string): BlockPatch =
  ## Retrieves a block patch from the master tileset, with the given name.
  m.g.masterTileset.blockPatch(name)


# registry: blocks

proc registerBlock*(m: Module, name: string, desc: sink Block): BlockId =
  ## Registers a block using the given descriptor, with the given name.
  ## The given name is namespaced automatically.

  result = m.r.blockRegistry.register(m.namespaced(name), desc)
  hint "registered block ", m.namespaced(name), " -> ", result

proc blockId*(m: Module, name: string): BlockId =
  ## Gets the block ID for the given name.
  m.r.blockRegistry.id(name)

# as much as i don't like using ``getX``, ``block`` is a keyword in Nim so
# this'll have to do
proc getBlock*(m: Module, id: BlockId): lent Block =
  ## Returns an immutable reference to the block descriptor with the given ID.
  m.r.blockRegistry.get(id)

proc getBlock*(m: Module, name: string): lent Block =
  ## Returns an immutable reference to the block descriptor with the given name.
  m.r.blockRegistry.get(name)


# registry: items

proc registerItem*(m: Module, name: string, desc: sink Item): ItemId =
  ## Registers an item using the given descriptor, with the given name.
  ## The name is namespaced automatically.

  result = m.r.itemRegistry.register(m.namespaced(name), desc)
  hint "registered item ", m.namespaced(name), " -> ", result

proc itemId*(m: Module, name: string): ItemId =
  ## Gets the item ID for the given name.
  m.r.itemRegistry.id(name)

proc getItem*(m: Module, id: ItemId): lent Item =
  ## Returns an immutable reference to the item with the given ID.
  m.r.itemRegistry.get(id)

proc getItem*(m: Module, name: string): lent Item =
  ## Returns an immutable reference to the item with the given name.
  m.r.itemRegistry.get(name)


# registry: world generators

proc registerWorldGenerator*(m: Module, name: string,
                             desc: sink WorldGenerator): WorldGeneratorId =
  ## Registers a world generator using the given desciptor, with the given name.
  ## The name is namespaced automatically.

  result = m.r.worldGenRegistry.register(m.namespaced(name), desc)
  hint "registered world generator ", m.namespaced(name), " -> ", result

proc worldGeneratorId*(m: Module, name: string): WorldGeneratorId =
  ## Gets the world generator ID for the given name.
  m.r.worldGenRegistry.id(name)

proc getWorldGenerator*(m: Module, id: WorldGeneratorId): lent WorldGenerator =
  ## Returns an immutable reference to the world generator with the given ID.
  m.r.worldGenRegistry.get(id).WorldGenerator

proc getWorldGenerator*(m: Module, name: string): lent WorldGenerator =
  ## Returns an immutable reference to the world generator with the given name.
  m.r.worldGenRegistry.get(name).WorldGenerator
