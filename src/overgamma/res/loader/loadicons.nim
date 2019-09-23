#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import os
import tables

import rapid/res/textures

import ../../debug
import ../../res

proc loadIcons*() =
  info("Loading", "icons")
  const Icons = Data/"icons"
  for fp in walkDirRec(Icons, relative = true):
    let (_, name, ext) = fp.splitFile()
    if ext == ".png":
      verbose("Icon:", name)
      icons.add(name, loadRTexture(Icons/fp))
  verbose("Icons", "finished")
