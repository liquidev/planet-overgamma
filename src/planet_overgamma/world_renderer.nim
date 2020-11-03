## Everything related to rendering the world - generating the mesh, executing
## the appropriate draw calls, etc.

import aglet
import rapid/ec
import rapid/graphics
import rapid/graphics/atlas_texture
import rapid/graphics/tracers
import rapid/math/rectangle

import common
import registry
import resources
import tiles
import tileset
import world

proc updateMesh*(world: World, g: Game, br: BlockRegistry,
                 chunkPosition: Vec2i) =
  ## Updates a chunk's mesh. This must be called every time a chunk is updated,
  ## otherwise a chunk's actual blocks and graphics will go out of sync.

  var chunk = addr world.tilemap.chunk(chunkPosition)

  if chunk.user.mesh == nil:
    chunk.user.mesh = g.window.newMesh[:Vertex](usage = muStatic,
                                                primitive = dpTriangles)

  let tileSize = world.tilemap.tileSize

  var
    mesh = chunk.user.mesh
    vertices: seq[Vertex]
    indices: seq[uint16]

  proc vertex(position, uv: Vec2f, color: Vec4f): uint16 =
    result = vertices.len.uint16
    vertices.add(Vertex(position: position, uv: uv, color: color))

  proc rect(position, uv: Rectf, color: Vec4f) =
    let
      topLeft = vertex(position.topLeft, uv.topLeft, color)
      topRight = vertex(position.topRight, uv.topRight, color)
      bottomRight = vertex(position.bottomRight, uv.bottomRight, color)
      bottomLeft = vertex(position.bottomLeft, uv.bottomLeft, color)
    indices.add([topLeft, topRight, bottomRight,
                 bottomRight, bottomLeft, topLeft])

  proc tile(positionInChunk: Vec2i, tile: Tile, background: bool) =

    let position = chunkPosition * ChunkSize + positionInChunk

    template connectsTo(dx, dy: int32): bool =
      var
        otherMapTile = world[position + vec2i(dx, dy)]
        other =
          if background: otherMapTile.background
          else: otherMapTile.foreground
      tile.connectsTo(other)

    let
      positionRect = rectf(positionInChunk.vec2f * tileSize, tileSize)
      color =
        if background: vec4f(vec3f(0.8), 1.0)
        else: vec4f(1.0)
    case tile.kind
    of tkEmpty: discard
    of tkBlock:
      let desc = br.get(tile.blockId)
      case desc.graphicKind
      of bgkSingle:
        rect(positionRect, desc.graphic, color)
      of bgkAutotile:
        # gotta love nim's flexible call syntax
        let set = TileSideSet:
          (connectsTo(dx =  1, dy =  0).ord shl tsRight.uint8) or
          (connectsTo(dx =  0, dy =  1).ord shl tsBottom.uint8) or
          (connectsTo(dx = -1, dy =  0).ord shl tsLeft.uint8) or
          (connectsTo(dx =  0, dy = -1).ord shl tsTop.uint8)
        rect(positionRect, desc.patch[set], color)

  for positionInChunk, tile in tiles(chunk[]):
    tile(positionInChunk, tile.background, background = true)
    tile(positionInChunk, tile.foreground, background = false)

  mesh.uploadVertices(vertices)
  mesh.uploadIndices(indices)

iterator chunksInViewport(world: World, viewport: Rectf,
                          scale: float32): (Vec2i, var Chunk) =
  ## Yields all chunks in the given viewport rectangle.

  template toChunkCoordinates(pos: Vec2f): Vec2i =
    floor(pos / scale / world.tilemap.tileSize / ChunkSize).vec2i

  var
    topLeftChunk = toChunkCoordinates(viewport.topLeft)
    bottomRightChunk = toChunkCoordinates(viewport.bottomRight)
    worldWidthInChunks = world.width / ChunkSize

  for y in topLeftChunk.y..bottomRightChunk.y:
    for x in topLeftChunk.x..bottomRightChunk.x:
      let
        chunkPosition = vec2i(x.int32, y.int32)
        wrappedX = floorMod(chunkPosition.x.float32, worldWidthInChunks).int32
        wrappedPosition = vec2i(wrappedX, chunkPosition.y)
      if world.tilemap.hasChunk(wrappedPosition):
        yield (chunkPosition, world.tilemap.chunk(wrappedPosition))


proc renderWorld*(target: Target, g: Game, world: World, camera: Vec2f,
                  step: float32) =
  ## Renders the world using the given camera position. The camera looks at the
  ## center of the screen.

  const scale = 3.0

  let
    projection =
      ortho(0f, target.width.float32, target.height.float32, 0f, -1f, 1f)
    translation = camera * scale - target.size.vec2f / 2
    view = mat4f()
      .translate(vec3f(-translation, 0))
      .scale(scale)
    viewport = rectf(translation, target.size.vec2f)

  g.graphics.resetShape()

  for position, chunk in world.chunksInViewport(viewport, scale):
    let
      offset = vec2f(position * ChunkSize) *
               world.tilemap.tileSize
      mesh = chunk.user.mesh
      model = mat4f().translate(vec3f(offset, 0))
    target.draw(g.programPlain, mesh, uniforms {
      model: model,
      view: view,
      projection: projection,
      surface: g.masterTileset.atlas.sampler(
        minFilter = fmNearest,
        magFilter = fmNearest,
      )
    }, g.dpDefault)

  g.graphics.transform:
    g.graphics.translate(-translation)
    g.graphics.scale(scale)
    world.entities.shape(g.graphics, step)

  g.graphics.draw(target)

