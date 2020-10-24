## World type and modification.

import std/tables

import aglet
import glm/vec
import rapid/game/tilemap
import rapid/math/vector

import common
import tiles

const
  ChunkSize* = 8
  TileSize* = vec2f(8, 8)

type
  MapTile* = tuple[background, foreground: Tile]

  ChunkData* = object
    mesh*: Mesh[TexturedVertex]

  World* = ref object
    tilemap*: ChunkTilemap[MapTile, ChunkSize, ChunkSize]
    chunkData: Table[Vec2i, ChunkData]

const
  emptyMapTile* = MapTile (emptyTile, emptyTile)

proc newWorld*(): World =
  ## Creates a new, blank world.

  new result
  result.tilemap =
    newChunkTilemap[MapTile, ChunkSize, ChunkSize](TileSize, emptyMapTile)

proc `[]`*(world: World, position: Vec2i): var MapTile =
  ## Returns a mutable reference to the map tile at the given position.
  world.tilemap[position]

proc `[]=`*(world: World, position: Vec2i, tile: sink MapTile) =
  ## Sets the tile at the given position.
  world.tilemap[position] = tile
