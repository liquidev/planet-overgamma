#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/world/sprite
import glm

type
  Player* = ref object of RSprite
    # metadata
    name*: string
    # movement
    maxSpeed*: Vec2[float]
    jumpTime*: float

const
  DefaultPlayerName* = "Radio"
