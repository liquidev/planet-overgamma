import tables

import rapid/gfx
import rapid/gfx/texatlas
import rapid/gfx/texpack
import rapid/gfx/text
import rapid/res/textures

import items/itemdb
import mods/moddef
import player/recipedb
import world/tiledb

type
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

include res/sheet

var
  args*: Table[string, string]
  settings*: Settings

  win*: RWindow
  sur*: RGfx

  mods*: Table[string, Mod]
  sheets*: Table[string, Sheet]

  tiles*: TileDatabase
  items*: ItemDatabase
  recipes*: RecipeDatabase
  icons*: Table[string, RTexture]

  radio*: Spritesheet

  firaSans*, firaSansB*: RFont

proc sheet*(name: string): Sheet =
  if name notin sheets:
    result = newSheet()
    sheets[name] = result
  else:
    result = sheets[name]

include res/effects

