#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx
import rapid/gfx/fxsurface

const
  FxQuantizeSrc* = """
    uniform float scale;

    vec4 rEffect(vec2 pos) {
      return rPixel(floor(pos / scale) * scale + 0.5);
    }
  """
  FxBoxBlurSrc* = """
    uniform int radius;

    vec4 rEffect(vec2 pos) {
      int loopMin = -(radius / 2);
      int loopMax = -loopMin;

      vec4 accum = vec4(0.0);
      float den = 0.0;
      for (int y = loopMin; y <= loopMax; ++y) {
        for (int x = loopMin; x <= loopMax; ++x) {
          accum += rPixel(pos + vec2(x, y));
          ++den;
        }
      }
      accum /= den;

      return accum;
    }
  """

var
  fx*: RFxSurface
  fxQuantize*: REffect
  fxBoxBlur*: REffect
