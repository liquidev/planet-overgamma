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
    accel*, decel*, jumpStrength*, jumpSustainTime*: float
    movingLeft*, movingRight*, jumping*: bool
    jumpTime*: float
    # Animations
    walkTime*: float
    facing*: HDirection
    # World interaction
    mode*: InteractMode
    # Laser
    laserCharge*, laserMaxCharge*, laserChargeSpeed*, laserMoveSpeed*: float
    laserMode*: LaserMode
    # Upgrades
    augments*: seq[PlayerAugment]
  InteractMode* = enum
    imWorld
    imWires
  LaserMode* = enum
    laserOff
    laserDestroy
    laserPlace
  PlayerAugment* = enum
    augmentBase

const
  DefaultPlayerName* = "Radio"
