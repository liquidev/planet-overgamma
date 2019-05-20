#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import tables

import rapid/gfx/surface
import rapid/gfx/texpack
import rapid/res/fonts
import rapid/res/images
import rapid/res/textures

type
  TerrainData* = ref object
    blocks*, fluids*, decor*: TableRef[(string, int), RTextureRect]

const
  Tc* = (minFilter: fltNearest, magFilter: fltNearest,
         wrapH: wrapRepeat, wrapV: wrapRepeat)
  Data* = "data"

var
  args*: TableRef[string, string]

  win*: RWindow
  gfx*: RGfx

  terrain*: RTexture
  terrainData*: TerrainData

  firaSans14*: RFont
