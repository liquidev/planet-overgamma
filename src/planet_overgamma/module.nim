## Modules, aka mods. They allow for easily extending the game in an organized
## manner.
##
## Ruby API coming soon.

import std/os
import std/strutils

import aglet/rect

import logger
import registry
import resources
import tileset
import tiles

type
  Module* = ref object
    g*: Game
    name*: string
    rootPath*: string

proc newModule*(g: Game, name, rootPath: string): Module =
  ## Creates a new game module.

  new result
  result.g = g
  result.name = name
  result.rootPath = rootPath

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

proc registerBlock*(m: Module, name: string, desc: sink Block): BlockId =
  ## Registers a block using the given descriptor, with the given name.
  ## The given name is namespaced automatically.

  result = m.g.blockRegistry.register(m.namespaced(name), desc)
  hint "registered block ", m.namespaced(name), " -> ", result

proc blockId*(m: Module, name: string): BlockId =
  ## Gets the block ID for the given name.
  m.g.blockRegistry.id(name)

# as much as i don't like using ``getX``, ``block`` is a keyword in Nim so
# this'll have to do
# the ruby API won't have this limitation as keywords are contextual and as far
# as i could tell ``block`` isn't a keyword in ruby anyways

proc getBlock*(m: Module, id: BlockId): lent Block =
  ## Returns an immutable reference to the block descriptor with the given ID.
  m.g.blockRegistry.get(id)

proc getBlock*(m: Module, name: string): lent Block =
  ## Returns an immutable reference to the block descriptor with the given name.
  m.g.blockRegistry.get(name)
