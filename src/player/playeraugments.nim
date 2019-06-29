#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import glm

import playerdef

proc updateAugments*(player: Player) =
  player.accel = 0
  player.decel = 0
  player.jumpStrength = 0
  player.jumpSustainTime = 0
  player.laserMaxCharge = 0
  player.laserChargeSpeed = 0
  player.laserMoveSpeed = 0

  for aug in player.augments:
    case aug
    of augmentBase:
      player.accel += 0.25
      player.decel += 0.8
      player.jumpStrength += 2.0
      player.jumpSustainTime += 10.0
