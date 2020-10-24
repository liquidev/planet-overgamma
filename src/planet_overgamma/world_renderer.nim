## Everything related to rendering the world - generating the mesh, executing
## the appropriate draw calls, etc.

import aglet
import rapid/math/rectangle

import common
import registry
import resources
import tiles
import tileset
import world

proc updateMesh*(world: World, g: Game, br: BlockRegistry, chunk: var Chunk) =
  ## Updates a chunk's mesh. This must be called every time a chunk is updated,
  ## otherwise a chunk's actual blocks and graphics will go out of sync.

  if chunk.user.mesh == nil:
    chunk.user.mesh = g.window.newMesh[:Vertex](usage = muStatic,
                                                primitive = dpTriangles)

  let tileSize = world.tilemap.tileSize

  var
    tilemap = world.tilemap
    mesh = chunk.user.mesh
    vertices: seq[Vertex]
    indices: seq[uint16]

  {.push inline, stacktrace: off.}

  proc vertex(position, uv: Vec2f, color: Vec4f): uint16 =
    result = vertices.len.uint16
    vertices.add(Vertex(position: position, uv: uv, color: color))

  proc rect(position, uv: Rectf, color: Vec4f) =
    let
      topLeft = vertex(position.topLeft, uv.bottomLeft, color)
      topRight = vertex(position.topRight, uv.bottomRight, color)
      bottomRight = vertex(position.bottomRight, uv.topRight, color)
      bottomLeft = vertex(position.bottomLeft, uv.topLeft, color)
    indices.add([topLeft, topRight, bottomRight,
                 topRight, bottomRight, bottomLeft])

  proc tile(position: Vec2i, tile: Tile, background: bool) =

    template connectsTo(dx, dy: int32): bool =
      var
        otherMapTile = addr tilemap[position + vec2i(dx, dy)]
        other =
          if background: otherMapTile.background
          else: otherMapTile.foreground
      tile.connectsTo(other)

    let
      positionRect = rectf(position.vec2f * tileSize, tileSize)
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
          connectsTo(dx =  1, dy =  0).ord * tsseRight or
          connectsTo(dx =  0, dy =  1).ord * tsseBottom or
          connectsTo(dx = -1, dy =  0).ord * tsseLeft or
          connectsTo(dx =  0, dy = -1).ord * tsseTop
        rect(positionRect, desc.patch[set], color)

  {.pop.}

  for position, tile in tiles(chunk):
    tile(position, tile.background, background = true)
    tile(position, tile.foreground, background = false)

  mesh.uploadVertices(vertices)
  mesh.uploadIndices(indices)
