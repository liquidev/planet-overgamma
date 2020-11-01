## World type and modification.

import std/sets
import std/tables

import aglet
import rapid/ec
import rapid/game/tilemap
import rapid/math/vector
import rapid/physics/chipmunk

import common
import tiles

export tilemap except Chunk

const
  ChunkSize* = 8
  TileSize* = vec2f(8, 8)

type
  MapTile* = tuple[background, foreground: Tile]

  TileCollisionShapes* = tuple[right, bottom, left, top: SegmentShape]
  ChunkCollisionData* = object
    body*: Body
    segments*: array[ChunkSize * ChunkSize, TileCollisionShapes]

  ChunkData* = object
    mesh*: Mesh[Vertex]
    collision*: ChunkCollisionData

  Chunk* = UserChunk[MapTile, ChunkSize, ChunkSize, ChunkData]
  Tilemap* = UserChunkTilemap[MapTile, ChunkSize, ChunkSize, ChunkData]
    # jesus fuck please send help

  World* = ref object
    tilemap*: Tilemap
    space*: Space
    entities*: seq[RootEntity]
    dirtyChunks: HashSet[Vec2i]
    width: int32

const
  emptyMapTile* = MapTile (emptyTile, emptyTile)

proc newWorld*(width: int32): World =
  ## Creates a new, blank world.

  new result
  result.tilemap =
    newUserChunkTilemap[MapTile, ChunkSize, ChunkSize, ChunkData](
      TileSize, emptyMapTile
    )
  result.space = newSpace(gravity = vec2f(0, 9.81))
  result.dirtyChunks.init()
  result.width = width

proc repeatX(world: World, position: Vec2i): Vec2i {.inline.} =
  # the world is repeated once on the left and once on the right instead of
  # infinitely because a couple of `if` statements is cheaper than `mod`
  result = position
  result.x += world.width * int32(result.x < 0)
  result.x -= world.width * int32(result.x >= world.width)

proc `[]`*(world: World, position: Vec2i): var MapTile =
  ## Returns a mutable reference to the map tile at the given position.
  ##
  ## The tile coordinates are wrapped so that there exist two copies immediately
  ## to the left (x < 0) and to the right (x ≥ width) of the world. This is done
  ## for the sake of better collision map generation and generally making things
  ## easier to work with internally. User code should not rely on this behavior
  ## and instead only work within the bounds of `x in [0; width)`.
  world.tilemap[world.repeatX(position)]

proc getOrCreate*(world: World, position: Vec2i): var MapTile =
  ## Returns a mutable reference to the map tile at the given position.
  ## Creates a chunk if the position lands out of bounds.

  let position = world.repeatX(position)
  if not world.tilemap.isInbounds(position):
    echo "getOrCreate: Creating chunk ", position
    # discard world.tilemap.createChunk(world.tilemap.chunkPosition(position))
  result = world.tilemap[position]

proc `[]=`*(world: World, position: Vec2i, tile: sink MapTile) =
  ## Sets the tile at the given position. This marks the chunk as dirty.
  ## It does not perform any chunk updates for efficiency, so don't forget to
  ## call ``updateChunks`` after you're done updating tiles.
  ##
  ## Same wrapping rules as ``[]`` apply.

  let position = world.repeatX(position)
  world.tilemap[position] = tile
  world.dirtyChunks.incl(world.tilemap.chunkPosition(position))

proc width*(world: World): int32 =
  ## Returns the width of the world. Note that *only* the width is finite
  ## because the world wraps around (like a planet, duh), but the height isn't
  ## because the Earth is a cylinder.
  world.width

import resources
import world_collisions
import world_renderer

proc updateChunk*(world: World, g: Game, br: BlockRegistry, position: Vec2i) =
  ## Updates a single chunk's mesh and physics body.

  world.updateMesh(g, br, position)
  world.updateBody(br, position)

  world.dirtyChunks.excl(position)

proc updateChunks*(world: World, g: Game, br: BlockRegistry) =
  ## Updates all chunks flagged as dirty.

  while world.dirtyChunks.len > 0:  # for position in world.dirtyChunks:
    let position = world.dirtyChunks.pop()
    world.updateChunk(g, br, position)
