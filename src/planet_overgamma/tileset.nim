## Cool tileset manager. Allows you to load block patches easily.

import std/tables

import aglet
import glm/vec
import rapid/graphics/atlas_texture
import rapid/graphics/image

import logger

type
  Tileset* = ref object
    # rgba8, because we don't need HDR anyways
    atlas*: AtlasTexture[Rgba8]
    singles: Table[string, Rectf]
    blockPatches: Table[string, BlockPatch]

  TileSide* = enum
    tsRight
    tsBottom
    tsLeft
    tsTop

  TileSideSet* = distinct range[0..15]

  BlockPatch* = array[TileSideSet, Rectf]


# tile side set

const
  # values for internal use
  tsseRight* = 1 shl tsRight.uint8
  tsseBottom* = 1 shl tsBottom.uint8
  tsseLeft* = 1 shl tsLeft.uint8
  tsseTop* = 1 shl tsTop.uint8

  # the empty tile side set
  tssEmpty* = TileSideSet(0)

proc inclRight*(set: var TileSideSet) =
  ## Includes the right side in the given set.
  range[0..15](set) = set.uint8 or tsseRight

proc inclBottom*(set: var TileSideSet) =
  ## Includes the bottom side in the given set.
  range[0..15](set) = set.uint8 or tsseBottom

proc inclLeft*(set: var TileSideSet) =
  ## Includes the left side in the given set.
  range[0..15](set) = set.uint8 or tsseLeft

proc inclTop*(set: var TileSideSet) =
  ## Includes the top side in the given set.
  range[0..15](set) = set.uint8 or tsseTop

proc right*(set: TileSideSet): TileSideSet =
  ## Returns a copy of the given ``set`` with the right side included.
  result = set
  result.inclRight()

proc bottom*(set: TileSideSet): TileSideSet =
  ## Returns a copy of the given ``set`` with the bottom side included.
  result = set
  result.inclBottom()

proc left*(set: TileSideSet): TileSideSet =
  ## Returns a copy of the given ``set`` with the left side included.
  result = set
  result.inclLeft()

proc top*(set: TileSideSet): TileSideSet =
  ## Returns a copy of the given ``set`` with the top side included.
  result = set
  result.inclTop()

proc `==`*(a, b: TileSideSet): bool {.borrow.}


# tileset

proc newTileset*(window: Window, atlasSize: Vec2i): Tileset =
  ## Creates a new empty tileset.

  new result
  result.atlas = window.newAtlasTexture[:Rgba8](atlasSize)

proc loadSingle*(tileset: Tileset, name, filename: string): Rectf =
  ## Loads a single sprite (or just "single") from the given path.

  hint "loading single ", name, " from ", filename

  let image = loadPngImage(filename)
  result = tileset.atlas.add(image)
  tileset.singles[name] = result

proc loadBlockPatch*(tileset: Tileset, name, filename: string): BlockPatch =
  ## Loads a block patch from the given path.

  # block patches look like this:
  #
  # +-- --- --+ +-+
  # |.. ... ..| |.|
  # |.. ... ..| |.|
  #
  # |.. ... ..| |.|
  # |.. ... ..| |.|
  # |.. ... ..| |.|
  #
  # |.. ... ..| |.|
  # |.. ... ..| |.|
  # +-- --- --+ +-+
  # +-- --- --+ +-+
  # |.. ... ..| |.|
  # +-- --- --+ +-+
  #
  # the top left tile is (0, 0) and the bottom right tile is (3, 3)
  # you can see examples in /data/core/tiles

  hint "loading block patch ", name, " from ", filename

  let
    image = loadPngImage(filename)
    tileSize = vec2i(image.width, image.height) div vec2i(4)

  template add(x, y: int): Rectf =
    tileset.atlas.add(image[recti(vec2i(x, y) * tileSize, tileSize)])

  # this is a bunch of magic numbers but unfortunately i couldn't find a better
  # way of doing this. there seems to be no correlation between the order of
  # tiles on the image and a tile side set.
  result = [
    TileSideSet(0b0000): add(3, 3),
    TileSideSet(0b0001): add(0, 3),
    TileSideSet(0b0010): add(3, 0),
    TileSideSet(0b0011): add(0, 0),
    TileSideSet(0b0100): add(2, 3),
    TileSideSet(0b0101): add(1, 3),
    TileSideSet(0b0110): add(2, 0),
    TileSideSet(0b0111): add(1, 0),
    TileSideSet(0b1000): add(3, 2),
    TileSideSet(0b1001): add(0, 2),
    TileSideSet(0b1010): add(3, 1),
    TileSideSet(0b1011): add(0, 1),
    TileSideSet(0b1100): add(2, 2),
    TileSideSet(0b1101): add(1, 2),
    TileSideSet(0b1110): add(2, 1),
    TileSideSet(0b1111): add(1, 1),
  ]
  tileset.blockPatches[name] = result

proc single*(tileset: Tileset, name: string): Rectf =
  ## Returns a single from the tileset.
  tileset.singles[name]

proc blockPatch*(tileset: Tileset, name: string): BlockPatch =
  ## Returns a block patch from the tileset.
  tileset.blockPatches[name]
