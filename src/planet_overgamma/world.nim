## World type and modification.

import std/sets
import std/tables

import aglet
import rapid/game/tilemap
import rapid/math/vector

import common
import tiles

export tilemap except Chunk

const
  ChunkSize* = 8
  TileSize* = vec2f(8, 8)

type
  MapTile* = tuple[background, foreground: Tile]

  ChunkData* = object
    mesh*: Mesh[Vertex]

  Chunk* = UserChunk[MapTile, ChunkSize, ChunkSize, ChunkData]
  Tilemap* = UserChunkTilemap[MapTile, ChunkSize, ChunkSize, ChunkData]
    # jesus fuck please send help

  World* = ref object
    tilemap*: Tilemap
    dirtyChunks: HashSet[Vec2i]

const
  emptyMapTile* = MapTile (emptyTile, emptyTile)

proc newWorld*(): World =
  ## Creates a new, blank world.

  new result
  result.tilemap =
    newUserChunkTilemap[MapTile, ChunkSize, ChunkSize, ChunkData](
      TileSize, emptyMapTile
    )

proc `[]`*(world: World, position: Vec2i): var MapTile =
  ## Returns a mutable reference to the map tile at the given position.
  world.tilemap[position]

proc `[]=`*(world: World, position: Vec2i, tile: sink MapTile) =
  ## Sets the tile at the given position. This marks the chunk as dirty.
  ## It does not perform any chunk updates for efficiency, so don't forget to
  ## call ``updateChunks`` after you're done updating tiles.

  world.tilemap[position] = tile
  world.dirtyChunks.incl(world.tilemap.chunkPosition(position))

import resources
import world_renderer

proc updateChunk*(world: World, g: Game, br: BlockRegistry, position: Vec2i) =
  ## Updates a single chunk's mesh and physics body.

  var chunk = addr world.tilemap.chunk(position)
  world.updateMesh(g, br, chunk[])

  world.dirtyChunks.excl(position)

proc updateChunks*(world: World, g: Game, br: BlockRegistry) =
  ## Updates all chunks flagged as dirty.

  for position in world.dirtyChunks:
    world.updateChunk(g, br, position)
