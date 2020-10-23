## All sort of tile-related stuff.

import aglet/rect

import registry
import tileset


# block registry

type
  BlockId* = RegistryId[Block]

  BlockGraphicKind* = enum
    bgkSingle
    bgkAutotile

  Block* = object
    ## A block descriptor is a unique object stored in the block registry.
    ## Block descriptors include all the significant information about a block:
    ## its graphic, translation ID, hardness, etc.

    id*: BlockId

    case graphicKind*: BlockGraphicKind
    of bgkSingle:
      graphic*: Rectf
    of bgkAutotile:
      patch*: BlockPatch

  BlockRegistry* = ref object
    idReg: Registry[Block]
    blocks: seq[Block]

proc initBlock*(graphic: Rectf): Block =
  ## Creates a new single-graphic block.
  Block(graphicKind: bgkSingle, graphic: graphic)

proc initBlock*(patch: BlockPatch): Block =
  ## Creates a new auto-tile block.
  Block(graphicKind: bgkAutotile, patch: patch)

proc newBlockRegistry*(): BlockRegistry =
  ## Creates a new block registry.
  new result

proc register*(reg: BlockRegistry, name: string, desc: sink Block): BlockId =
  ## Registers a block into the block registry and returns its numeric ID.

  var desc = desc
  result = reg.idReg.register(name)
  desc.id = result
  reg.blocks.add(desc)

proc id*(reg: BlockRegistry, name: string): BlockId =
  ## Returns the block ID for the given block name. Raises an exception if there
  ## is no block with the given name.
  reg.idReg.id(name)

proc name*(reg: BlockRegistry, id: BlockId): string =
  ## Returns the block name for the given ID. Raises an exception if the ID is
  ## invalid (wasn't returned by this registry).
  reg.idReg.name(id)

proc descriptor*(reg: BlockRegistry, id: BlockId): lent Block =
  ## Returns the block descriptor with the given ID.
  reg.blocks[id.int]


# tile

type
  TileKind* = enum
    tkEmpty
    tkBlock

  Tile* = object
    ## A single map tile. Most of the fields are IDs for efficiency and easy
    ## serialization.

    case kind*: TileKind
    of tkEmpty: discard
    of tkBlock:
      blockId*: BlockId
