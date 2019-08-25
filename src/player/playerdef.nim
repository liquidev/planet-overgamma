#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/world/sprite

import ../gui/windows
import ../util/direction
import ../items/container
import ../world/world

type
  Player* = ref object of RSprite
    # Metadata
    world*: World
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
    laserMode*: LaserMode
    laserCharge*, laserChargeMax*, laserChargeSpeed*: float
    laserMaxReach*: float
    # Inventory
    inventory*: Container
    itemPopups*: seq[tuple[id: string, amt: float, time: float]]
    # Upgrades
    augments*: seq[PlayerAugment]
    # GUI
    winInventory*, winAssembler*: Window
  InteractMode* = enum
    imWorld
    imWires
  LaserMode* = enum
    laserOff
    laserDestroy
    laserPlace
  PlayerAugment* = enum
    augmentBase
    augmentDebug # --debug.augment

const
  DefaultPlayerName* = "Radio"
