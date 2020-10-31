## Generation of collision bodies for the world.

import glm/vec
import rapid/physics/chipmunk

import tiles
import registry
import world

proc updateBody*(world: World, br: BlockRegistry, chunkPosition: Vec2i) =
  ## Updates a chunk's collision body.

  # let me just take a moment to note that overgamma's collision stuff is not
  # very efficient. this is partially why i needed to create a chunk system,
  # so that the whole map wouldn't need to get updated if only a few blocks were
  # changed. this may not be great wrt resource usage but that's just how
  # chipmunk works.
  #
  # any further optimizations such as merging long segments into one will result
  # in several issues that i don't wanna deal with at this moment. after all,
  # nowadays our computers have gigabytes of memory, only problem is that
  # because this method's cache efficiency is quite literally shit the process
  # of generating all the segments will be slow af.
  # at least it's better than checking collision against a big bunch of
  # polygon shapes, or so i was told by the chipmunk docs.

  echo "updating chunk body for: ", chunkPosition

  var
    chunk = addr world.tilemap.chunk(chunkPosition)
    coll = addr chunk.user.collision

  let tileSize = world.tilemap.tileSize

  if coll.body == nil:
    coll.body.initStatic()
    coll.body.position = vec2f(chunkPosition * ChunkSize) * tileSize
    world.space.addBody(coll.body)

  for positionInChunk, mapTile in tiles(chunk[]):
    # only blocks can ever be solid. could you imagine a world where you
    # couldn't pass by machines? or swim in fluids?
    let tile = mapTile.foreground
    if tile.kind != tkBlock or not br.get(tile.blockId).isSolid: continue

    let position = chunkPosition * ChunkSize + positionInChunk
    var segments = block:
      let index = positionInChunk.x + positionInChunk.y * ChunkSize
      addr coll.segments[index]

    template isSolid(dx, dy: int): bool =
      let otherTile = world[position + vec2i(dx, dy)].foreground
      otherTile.kind == tkBlock and br.get(otherTile.blockId).isSolid

    template checkSide(sideIdent: untyped, tiledx, tiledy: int,
                       offsetA, offsetB: Vec2f) =
      if isSolid(tiledx, tiledy) and segments.sideIdent != nil:
        coll.body.removeShape(segments.sideIdent)
        segments.sideIdent = nil
      elif not isSolid(tiledx, tiledy) and segments.sideIdent == nil:
        let topLeft = positionInChunk.vec2f * tileSize
        segments.sideIdent = coll.body.newSegmentShape(
          topLeft + offsetA,
          topLeft + offsetB,
        )

    checkSide right,
      tiledx = 1, tiledy = 0,
      offsetA = vec2f(tileSize.x, 0), offsetB = tileSize
    checkSide bottom,
      tiledx = 0, tiledy = 1,
      offsetA = vec2f(0, tileSize.y), offsetB = tileSize
    checkSide left,
      tiledx = -1, tiledy = 0,
      offsetA = vec2f(0, 0), offsetB = vec2f(0, tileSize.y)
    checkSide top,
      tiledx = 0, tiledy = -1,
      offsetA = vec2f(0, 0), offsetB = vec2f(tileSize.x, 0)
