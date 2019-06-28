#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx
import rapid/world/sprite

import ../res
import ../util/direction
import playerdef

const
  Gravity = vec2(0.0, 0.10)
  Accel = 0.25
  Decel = 0.8
  JumpStrength = 2.0

  KLeft = keyA
  KRight = keyD
  KJump = keySpace

proc initControls*(player: Player) =
  win.onKeyPress do (win: RWindow, key: Key, scancode: int, mods: RModKeys):
    if key == KJump and player.vel.y == 0.0:
      player.jumpTime = 10.0

proc control(player: Player, step: float) =
  # controls
  if win.key(KLeft) == kaDown:
    player.force(vec2(-Accel, 0.0))
    player.facing = hdirLeft
  if win.key(KRight) == kaDown:
    player.force(vec2(Accel, 0.0))
    player.facing = hdirRight

  # movement
  if win.key(KJump) == kaDown:
    if player.jumpTime > 0.0:
      player.vel.y = -JumpStrength
    player.jumpTime -= step
  else:
    player.jumpTime = 0.0

  if player.vel.x > 0.05 or player.vel.x < -0.05:
    player.walkTime += step * abs(player.vel.x)
  else:
    player.walkTime = 0
  if player.walkTime > 20:
    player.walkTime = 0

proc physics*(player: Player, step: float) =
  player.control(step)

  player.force(Gravity)
  player.vel.x *= Decel
