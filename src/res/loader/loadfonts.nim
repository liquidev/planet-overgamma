#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import os

import rapid/res/fonts

import ../../debug
import ../resources

proc loadFonts*() =
  info("Loading", "fonts")
  const
    Fonts = Data/"fonts"
    FiraSans = Fonts/"Fira_Sans"
  verbose("Font:", "Fira Sans")
  firaSans14 = newRFont(FiraSans/"FiraSans-Regular.ttf", Tc, 14)
  verbose("Fonts", "finished")
