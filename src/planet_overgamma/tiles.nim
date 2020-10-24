## All sort of tile-related stuff.

import aglet/rect

import registry
import tileset


# block

type
  BlockGraphicKind* = enum
    bgkSingle
    bgkAutotile

  BlockId* = RegistryId[Block]

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

  BlockRegistry* = Registry[Block]

proc initBlock*(graphic: Rectf): Block =
  ## Creates a new single-graphic block.
  Block(graphicKind: bgkSingle, graphic: graphic)

proc initBlock*(patch: BlockPatch): Block =
  ## Creates a new auto-tile block.
  Block(graphicKind: bgkAutotile, patch: patch)


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

proc `==`*(a, b: Tile): bool =
  ## Compares two tiles for equality.

  if a.kind != b.kind: return false

  case a.kind
  of tkEmpty: true
  of tkBlock: a.blockId == b.blockId

const
  emptyTile* = Tile(kind: tkEmpty)
    ## Empty tile constant.

proc blockTile*(id: BlockId): Tile =
  ## Creates a new block tile.
  Tile(kind: tkBlock, blockId: id)
