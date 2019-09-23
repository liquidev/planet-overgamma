#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import tables

import rapid/gfx
import rapid/gfx/texatlas
import rapid/gfx/texpack
import rapid/gfx/text
import rapid/res/textures

import player/recipedb
import world/tiledb

type
  TerrainData* = ref object
    blocks*, fluids*, decor*: Table[(string, int), RTextureRect]
  Spritesheet* = object
    tex*: RTexture
    atl*: RAtlas

  Settings* = object
    general*: GeneralSettings
    graphics*: GraphicsSettings
  GeneralSettings* = object
    language*: string
  GraphicsSettings* = object
    pixelate*, blurBehindUI*: bool
    msaa*: range[0..8]
    vsync*: bool

const
  Tc* = (minFilter: fltNearest, magFilter: fltNearest,
         wrapH: wrapRepeat, wrapV: wrapRepeat)
  Data* = "data"

var
  args*: Table[string, string]
  settings*: Settings

  win*: RWindow
  sur*: RGfx

  terrain*: RTexture
  terrainData*: TerrainData
  itemSprites*: RTexture
  itemSpriteData*: Table[string, RTextureRect]
  tiles*: TileDatabase
  recipes*: RecipeDatabase
  icons*: Table[string, RTexture]

  radio*: Spritesheet

  firaSans*, firaSansB*: RFont

include res/effects
