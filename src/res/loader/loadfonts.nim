#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import os

import rapid/res/fonts

import ../../debug
import ../../res

proc loadFonts*() =
  info("Loading", "fonts")
  const
    Fonts = Data/"fonts"
    FiraSans = Fonts/"Fira_Sans"
  verbose("Font:", "Fira Sans")
  firaSans = newRFont(FiraSans/"FiraSans-Regular.ttf", 14, 0, Tc)
  firaSansB = newRFont(FiraSans/"FiraSans-Bold.ttf", 14, 0, Tc)
  verbose("Fonts", "finished")
