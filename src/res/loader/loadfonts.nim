#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import os

import rapid/gfx/text

import ../../debug
import ../../res

proc loadFonts*() =
  info("Loading", "fonts")
  const
    Fonts = Data/"fonts"
    FiraSans = Fonts/"Fira_Sans"
  verbose("Font:", "Fira Sans")
  firaSans = loadRFont(FiraSans/"FiraSans-Regular.ttf", 14, 0, Tc)
  firaSansB = loadRFont(FiraSans/"FiraSans-Bold.ttf", 14, 0, Tc)
  verbose("Fonts", "finished")
