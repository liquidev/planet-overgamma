#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import os
import tables

import rapid/gfx/texpack
import rapid/res/images
import rapid/res/textures

import ../../debug
import ../../res

proc loadItems*(tex: var RTexture): Table[string, RTextureRect] =
  info("Loading", "items")
  var
    packer = newRTexturePacker(128, 128, Tc)
    nameList: seq[string]
    imageList: seq[RImage]
  const Items = Data/"items"
  for fp in walkDirRec(Items, relative = true):
    let (dir, name, ext) = fp.splitFile()
    if ext == ".png":
      let
        itemName = (if dir != "": dir & ":" else: "") & name
        img = loadRImage(Items/fp)
      verbose("Item:", itemName, " <- ", fp)
      nameList.add(itemName)
      imageList.add(img)
  info("Packing", "items")
  let uv = packer.place(imageList)
  for i, v in uv:
    result.add(nameList[i], v)
  tex = packer.texture
  verbose("Items", "finished loading")
