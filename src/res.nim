#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import tables

import rapid/gfx
import rapid/gfx/texatlas
import rapid/gfx/texpack
import rapid/res/fonts
import rapid/res/images
import rapid/res/textures

import world/tiledb

type
  TerrainData* = ref object
    blocks*, fluids*, decor*: Table[(string, int), RTextureRect]
  Spritesheet* = object
    tex*: RTexture
    atl*: RAtlas

const
  Tc* = (minFilter: fltNearest, magFilter: fltNearest,
         wrapH: wrapRepeat, wrapV: wrapRepeat)
  Data* = "data"

var
  args*: Table[string, string]

  win*: RWindow
  sur*: RGfx

  terrain*: RTexture
  terrainData*: TerrainData
  itemSprites*: RTexture
  itemSpriteData*: Table[string, RTextureRect]
  tiles*: TileDatabase

  radio*: Spritesheet

  firaSans14*, firaSans14b*: RFont

include res/effects
