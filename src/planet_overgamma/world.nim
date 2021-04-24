## World type and modification.

import std/math
import std/options
import std/random
import std/sets
import std/sugar
import std/tables

import aglet
import rapid/ec
import rapid/game/tilemap
import rapid/math/units
import rapid/math/vector
import rapid/physics/simple

import camera
import common
import ecext
import game_registry
import items
import item_entity
import tiles

export tilemap except Chunk

const
  ChunkSize* = 8
  TileSize* = vec2f(8, 8)

type
  MapTile* = tuple[background, foreground: Tile]

proc isSolid*(tile: MapTile): bool =
  ## Returns whether the given map tile is solid.
  tile.foreground.kind == tkBlock and tile.foreground.isSolid

proc get*(tile: MapTile, background: bool): Tile =
  ## Returns the background tile if ``background == true`` or the foreground
  ## tile if ``background == false``.
  if background: tile.background
  else: tile.foreground

proc get*(tile: var MapTile, background: bool): var Tile =
  if background:
    result = tile.background
  else:
    result = tile.foreground

type
  ChunkData* = object
    mesh*: Mesh[Vertex]

  Chunk* = UserChunk[MapTile, ChunkSize, ChunkSize, ChunkData]
  Tilemap* = UserChunkTilemap[MapTile, ChunkSize, ChunkSize, ChunkData]
    # jesus fuck please send help

  World* = ref object
    r*: GameRegistry

    tilemap*: Tilemap
    space*: Space[World]
    entities*: seq[RootEntity]

    camera*: Camera

    playerSpawnPoint*: Vec2f
      ## The position at which players are spawned. This should be initialized
      ## to some place above ground so that players don't spawn inside of the
      ## map, *from which there is no escape.*

    width: int32
    dirtyChunks: HashSet[Vec2i]
    spawnedEntities: seq[RootEntity]
    entitiesSeqInUse: bool

const
  emptyMapTile* = MapTile (emptyTile, emptyTile)


# basics

proc tileSize*(world: World): Vec2f =
  ## Returns the tile size of the world.
  TileSize

proc repeatX(world: World, position: Vec2i): Vec2i {.inline.} =
  # the world is repeated once on the left and once on the right instead of
  # infinitely because a couple of comparisons is faster than `mod`
  result = position
  result.x += world.width * int32(result.x < 0)
  result.x -= world.width * int32(result.x >= world.width)

proc repeatChunkX(world: World, position: Vec2i): Vec2i {.inline.} =

  let widthInChunks = world.width div ChunkSize

  result = position
  result.x += widthInChunks * int32(result.x < 0)
  result.x -= widthInChunks * int32(result.x >= widthInChunks)

proc `[]`*(world: World, position: Vec2i): var MapTile =
  ## Returns a mutable reference to the map tile at the given position.
  ##
  ## The tile coordinates are wrapped so that there exist two copies immediately
  ## to the left (x < 0) and to the right (x ≥ width) of the world. This is done
  ## for the sake of better collision map generation and generally making things
  ## easier to work with internally. User code should not rely on this behavior
  ## and instead only work within the bounds of `x in [0; width)`.
  world.tilemap[world.repeatX(position)]

proc `[]=`*(world: World, position: Vec2i, tile: sink MapTile) =
  ## Sets the tile at the given position. This marks the chunk as dirty.
  ## It does not perform any chunk updates for efficiency, so don't forget to
  ## call ``updateChunks`` after you're done updating tiles.
  ##
  ## Same wrapping rules as ``[]`` apply.

  let position = world.repeatX(position)
  world.tilemap[position] = tile

  let chunkPosition = world.tilemap.chunkPosition(position)
  world.dirtyChunks.incl(chunkPosition)

  # chunk borders also need to be handled because otherwise tiling will
  # be messed up
  let positionInChunk = world.tilemap.positionInChunk(position)

  template markDirty(dx, dy: int32) =
    world.dirtyChunks.incl(world.repeatChunkX(chunkPosition + vec2i(dx, dy)))

  if positionInChunk.x == 0:
    markDirty(-1, 0)
  elif positionInChunk.x == ChunkSize - 1:
    markDirty(1, 0)

  if positionInChunk.y == 0:
    markDirty(0, -1)
  elif positionInChunk.y == ChunkSize - 1:
    markDirty(0, 1)

iterator tiles*(world: World): (Vec2i, var MapTile) =
  ## Iterates over all of the world's tiles.

  for position, tile in tiles(world.tilemap):
    yield (position, tile)

proc unitWidth*(world: World): float32 =
  ## Returns the width of the world in space units (1 tile = 8 units).
  world.width.float32 * world.tileSize.x

proc newWorld*(r: GameRegistry, width: int32): World =
  ## Creates a new, blank world.

  new result
  result.r = r
  result.tilemap =
    newUserChunkTilemap[MapTile, ChunkSize, ChunkSize, ChunkData](
      TileSize, emptyMapTile
    )
  result.space = result.newSpace(gravity = vec2f(0, 1/320),
                                 spatialHashCellSize = 8)
  result.dirtyChunks.init()
  result.width = width

  result.space.boundsX = some(0f..result.unitWidth)

proc width*(world: World): int32 =
  ## Returns the width of the world. Note that *only* the width is finite
  ## because the world wraps around (like a planet, duh), but the height isn't
  ## because the Earth is a cylinder.
  world.width


# rendering

import resources
import world_renderer

proc updateChunk*(world: World, g: Game, position: Vec2i) =
  ## Updates a single chunk's mesh and physics body.

  world.updateMesh(g, position)

  world.dirtyChunks.excl(position)

proc updateChunks*(world: World, g: Game) =
  ## Updates all chunks flagged as dirty.

  while world.dirtyChunks.len > 0:
    let position = world.dirtyChunks.pop()
    world.updateChunk(g, position)


# simulation

proc update*(world: World) =
  ## Ticks a world once.

  world.entitiesSeqInUse = true

  world.entities.update(world.camera)
  world.entities.cleanup()
  world.space.update()
  world.entities.lateUpdate(world.camera)

  world.entitiesSeqInUse = false

  for entity in world.spawnedEntities:
    world.entities.add(entity)
  world.spawnedEntities.setLen(0)


# interaction

proc spawn*(world: World, entity: RootEntity) {.inline.} =
  ## Spawns a new entity into the world.
  ## This is safe to use during iteration of entities, eg. in a component's
  ## update callback.
  ## Spawned entities are scheduled to be added to the entity list once
  ## iteration ends.

  if world.entitiesSeqInUse:
    world.spawnedEntities.add(entity)
  else:
    world.entities.add(entity)

proc dropItem*(world: World, tilePosition: Vec2i, stack: ItemStack) =
  ## Spawns a new item entity at the given tile position.

  let
    wrappedTilePosition =
      vec2i(tilePosition.x.floorMod(world.width), tilePosition.y)
    position =
      wrappedTilePosition.vec2f * world.tileSize +
      world.tileSize / 2 - ItemHitboxSize / 2
    velocity = rand(180f..360f).Degrees.toVector * rand(1f..2f)
    entity = world.space.newItemEntity(world.r, position, velocity, stack)
  world.spawn(entity)

proc dropItem*(world: World, tilePosition: Vec2i, drop: ItemDrop) {.inline.} =
  ## Drops an item according to the given ``drop``.
  world.dropItem(tilePosition, drop.roll())

proc dropItems*(world: World, tilePosition: Vec2i,
                drops: ItemDrops) {.inline.} =
  ## Drops items according to the given ``drops``.

  for stack in drops.roll():
    world.dropItem(tilePosition, stack)

proc destroyTile*(world: World, position: Vec2i, background: bool) =
  ## Destroys the tile at the given position, dropping items at its location.

  var mapTile = world[position]
  let tile = mapTile.get(background)

  if tile.kind != tkEmpty:
    mapTile.get(background) = emptyTile
    world[position] = mapTile

    case tile.kind
    of tkEmpty: discard
    of tkBlock:
      let drops = world.r.blockRegistry.get(tile.blockId).drops
      world.dropItems(position, drops)


# x=0 seam helpers

iterator crossSeamDeltas*(world: World, a, b: Vec2f): Vec2f =
  ## Iterates through all of the bodies' possible delta positions, taking the
  ## x=0 seam into account. Note that this doesn't do any interpolation, so this
  ## shouldn't be used in draw procedures.

  template getDelta(xoffset: float32): Vec2f =
    (b - vec2f(xoffset, 0)) - a

  yield getDelta(-world.unitWidth)
  yield getDelta(0)
  yield getDelta(world.unitWidth)
