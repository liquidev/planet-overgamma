#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import os
import tables
import times

import rapid/gfx/texpack
import rapid/res/images
import rapid/res/textures

import ../../debug
import ../resources

proc loadTerrain*(tex: var RTexture): TerrainData =
  let startTime = epochTime()
  info("Loading", "terrain textures")
  new(result)
  var packer = newRTexturePacker(256, 256, Tc)
  template autoPlace(tmpl, table, name) {.dirty.} =
    template tmpl(x, y, n) {.dirty.} =
      result.table.add((name, n),
                       packer.place(w, h,
                                    img.subimg(x * w, y * h, w, h).caddr))
  block loadBlocks:
    info("Loading", "blocks")
    result.blocks = newTable[(string, int), RTextureRect]()
    autoPlace(bl, blocks, blockName)
    for fp in walkDirRec(Data/"tiles"/"blocks", relative = true):
      let (dir, name, ext) = fp.splitFile()
      if ext == ".png":
        let
          blockName = (if dir != "": dir & ":" else: "") & name
          img = newRImage(Data/"tiles"/"blocks"/fp)
          w = int(img.width / 4)
          h = int(img.height / 4)
        verbose("Block:", blockName, " <- ", fp)
        #          UDLR              UDLR              UDLR              UDLR
        bl(0, 0, 0b0101); bl(1, 0, 0b0111); bl(2, 0, 0b0110); bl(3, 0, 0b0100)
        bl(0, 1, 0b1101); bl(1, 1, 0b1111); bl(2, 1, 0b1110); bl(3, 1, 0b1100)
        bl(0, 2, 0b1001); bl(1, 2, 0b1011); bl(2, 2, 0b1010); bl(3, 2, 0b1000)
        bl(0, 3, 0b0001); bl(1, 3, 0b0011); bl(2, 3, 0b0010); bl(3, 3, 0b0000)
  block loadFluids:
    info("Terrain", "fluids")
    result.fluids = newTable[(string, int), RTextureRect]()
    autoPlace(fl, fluids, fluidName)
    for fp in walkDirRec(Data/"tiles"/"fluids", relative = true):
      let (dir, name, ext) = fp.splitFile()
      if ext == ".png":
        let
          fluidName = (if dir != "": dir & ":" else: "") & name
          img = newRImage(Data/"tiles"/"fluids"/fp)
          w = int(img.width / 4)
          h = img.height
        verbose("Fluid:", fluidName, " <- ", fp)
        #  shallow      medium       med→deep     deep
        fl(0, 0, 0); fl(1, 0, 1); fl(2, 0, 2); fl(3, 0, 3)
  block loadDecor:
    info("Terrain", "decor")
    result.decor = newTable[(string, int), RTextureRect]()
    autoPlace(dc, decor, decorName)
    for fp in walkDirRec(Data/"tiles"/"decor", relative = true):
      let (dir, name, ext) = fp.splitFile()
      if ext == ".png":
        let
          decorName = (if dir != "": dir & ":" else: "") & name
          img = newRImage(Data/"tiles"/"decor"/fp)
          w = img.height
          h = img.height
        verbose("Decor:", decorName, " <- ", fp)
        for n in 0..<int(img.width / w):
          dc(n, 0, n)
  tex = packer.texture
  let endTime = epochTime()
  verbose("Terrain", "finished, took ", endTime - startTime, " s")
