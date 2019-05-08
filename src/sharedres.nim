#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) iLiquid, 2018-2019
#--

import os
import tables

import rapid/gfx/texpack
import rapid/res/fonts
import rapid/res/images
import rapid/res/textures

type
  TerrainData* = ref object
    blocks*: TableRef[(string, int), RTextureRect]

const
  Tc* = (minFilter: fltNearest, magFilter: fltNearest,
         wrapH: wrapRepeat, wrapV: wrapRepeat)
  Data* = "data"

var
  terrain*: RTexture
  terrainData*: TerrainData

proc loadTerrain*(tex: var RTexture): TerrainData =
  new(result)
  var packer = newRTexturePacker(1024, 1024, Tc)
  block loadBlocks:
    result.blocks = newTable[(string, int), RTextureRect]()
    template bl(x, y, n) {.dirty.} =
      result.blocks.add((blockName, n),
                        packer.place(w, h,
                                     img.subimg(x * w, y * h, w, h).caddr))
    for fp in walkDirRec(Data/"tiles"/"blocks", relative = true):
      let
        (dir, name, ext) = fp.splitFile()
        blockName = dir & ":" & name
      if ext == ".png":
        let
          img = newRImage(Data/"tiles"/"blocks"/fp)
          w = int(img.width / 4)
          h = int(img.height / 4)
                 # UDLR              UDLR              UDLR              UDLR
        bl(0, 0, 0b0101); bl(1, 0, 0b0111); bl(2, 0, 0b0110); bl(3, 0, 0b0100)
        bl(0, 1, 0b1101); bl(1, 1, 0b1111); bl(2, 1, 0b1110); bl(3, 1, 0b1100)
        bl(0, 2, 0b1001); bl(1, 2, 0b1011); bl(2, 2, 0b1010); bl(3, 2, 0b1000)
        bl(0, 3, 0b0001); bl(1, 3, 0b0011); bl(2, 3, 0b0010); bl(3, 3, 0b0000)
  tex = packer.texture

proc load*() =
  terrainData = loadTerrain(terrain)
