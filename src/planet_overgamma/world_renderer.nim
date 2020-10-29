## Everything related to rendering the world - generating the mesh, executing
## the appropriate draw calls, etc.

import aglet
import rapid/graphics
import rapid/graphics/atlas_texture
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

proc renderWorld*(target: Target, g: Game, world: World, camera: Vec2f) =
  ## Renders the world using the given camera position. The camera looks at the
  ## center of the screen.

  let
    projection =
      ortho(0f, target.width.float32, target.height.float32, 0f, -1f, 1f)
    translation = -camera + target.size.vec2f / 2
    view = mat4f()
      .translate(vec3f(translation, 0))
      .scale(3)

  for position, chunk in chunks(world.tilemap):
    let
      offset = vec2f(position * vec2i(ChunkSize)) *
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
