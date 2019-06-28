#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx
import rapid/gfx/fxsurface

import ../../debug
import ../../res

proc loadEffects*() =
  info("Creating", "effect surface")
  fx = newRFxSurface(sur.canvas)
  info("Compiling", "effects")
  fxQuantize = fx.newREffect(FxQuantizeSrc)
  fxBoxBlur = fx.newREffect(FxBoxBlurSrc)
  verbose("Effects", "finished")
