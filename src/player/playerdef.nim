#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/world/sprite
import glm

import ../util/direction

type
  Player* = ref object of RSprite
    # Metadata
    name*: string
    # Movement
    maxSpeed*: Vec2[float]
    jumpTime*: float
    # Animations
    walkTime*: float
    facing*: HDirection
    # Laser
    laserCharge*, laserMaxCharge*, laserChargeSpeed*: float
    laserMode*: LaserMode
  LaserMode* = enum
    laserOff
    laserDestroy
    laserPlace

const
  DefaultPlayerName* = "Radio"
