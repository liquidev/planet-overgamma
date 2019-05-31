#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx/surface

const
  FxQuantizeSrc* = """
    uniform float scale;

    vec4 rEffect(vec2 pos) {
      return rPixel(floor(pos / scale) * scale + 0.5);
    }
  """

var
  fxQuantize*: REffect
