#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import os

import rapid/gfx/texatlas
import rapid/res/textures

import ../../debug
import ../../res

proc loadSprites*() =
  info("Loading", "sprites")
  const Sprites = Data/"sprites"
  template load(name; w = 8, h = 8) =
    verbose("Sprite:", astToStr(name), " (", w, "×", h, ")")
    let
      tex = loadRTexture(Sprites/(astToStr(name) & ".png"), Tc)
      atl = newRAtlas(tex, w, h, 0)
    name = Spritesheet(tex: tex, atl: atl)
  load(radio)
  verbose("Sprites", "finished")