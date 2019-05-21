#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

type
  Direction* = enum
    dirRight # 0 deg
    dirDown  # 90 deg
    dirLeft  # 180 deg
    dirUp    # 270 deg
  HDirection* = enum
    hdirRight
    hdirLeft
  VDirection* = enum
    vdirUp
    vdirDown
