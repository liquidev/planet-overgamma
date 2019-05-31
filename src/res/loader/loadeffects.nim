#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx/surface

import ../../debug
import ../resources

proc compileEffects*() =
  info("Compiling", "effects")
  fxQuantize = gfx.newREffect(FxQuantizeSrc)
  verbose("Effects", "finished")
