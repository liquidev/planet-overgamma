## A simple spritesheet manager.

import tables

import rapid/gfx/texpack
import rapid/res/images
import rapid/res/textures

type
  Sheet* = ref object
    texture: RTexture
    packer: RTexturePacker
    content: Table[string, seq[RTextureRect]]

const
  SheetSize* = 1024

proc newSheet*(): Sheet =
  ## Create a new sheet.
  new(result)
  result.packer = newRTexturePacker(SheetSize, SheetSize, Tc)
  result.texture = result.packer.texture

proc texture*(sheet: Sheet): RTexture = sheet.texture

proc add*(sheet: Sheet, image: RImage): RTextureRect =
  ## Add a single image to the sheet.
  result = sheet.packer.place(image)

proc add*(sheet: Sheet, images: seq[RImage]): seq[RTextureRect] =
  ## Add a list of images to the sheet.
  result = sheet.packer.place(images)

proc `[]`*(sheet: Sheet, name: string): seq[RTextureRect] =
  ## Retrieve the variants for the given key ``name``.
  result = sheet.content[name]
proc `[]=`*(sheet: Sheet, name: string, variants: seq[RTextureRect]) =
  ## Set the variants for the given key ``name``.
  sheet.content[name] = variants

