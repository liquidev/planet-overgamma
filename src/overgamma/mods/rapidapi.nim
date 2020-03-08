import glm/vec
import rapid/gfx/texpack
import rapid/res/images
import rapid/res/textures
import rapid/world/aabb

import euwren

proc wrenRapid*(wren: Wren) =
  wren.foreign(".glm/vec"):
    Vec2[float] -> Vec2:
      *new do (x, y: float) -> Vec2[float]:
        result = vec2(x, y)
  wren.foreign(".rapid/gfx/texpack"):
    RTextureRect: discard
  wren.foreign(".rapid/res/images"):
    RImage:
      *newRImage(int, int, string, int) -> new
      *loadRImage -> load
      *readRImagePng -> readPng
      ?area
      subimg
  wren.foreign(".rapid/res/textures"):
    RTextureFilter - flt
    RTextureWrap - wrap
    RTexturePixelFormat - fmt
    RTextureConfig: discard
    RTexture:
      *newRTexture(RImage, RTextureConfig) -> new
      *loadRTexture(string, RTextureConfig) -> load
      `$`(RTexture) -> toString
  wren.foreign(".rapid/world/aabb"):
    RAABounds:
      *newRAABB -> new
      ?left
      ?right
      ?top
      ?bottom
      intersects
      intersectsWhole
      has

