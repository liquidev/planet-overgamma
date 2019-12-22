import rapid/gfx/texpack
import rapid/res/images
import rapid/res/textures

import euwren

proc wrenRapid*(wren: Wren) =
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


