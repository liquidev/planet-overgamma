#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx/surface
import rapid/world/sprite

import ../res/resources
import playerdef

const
  Gravity = vec2(0.0, 0.2)
  Accel = 0.25
  Decel = 0.8
  JumpStrength = 2.0

  KLeft = keyA
  KRight = keyD
  KJump = keySpace

proc initControls*(player: Player) =
  win.onKeyPress do (win: RWindow, key: Key, scancode: int, mods: RKeyMods):
    if key == KJump and player.vel.y == 0.0:
      player.jumpTime = 10.0

proc control(player: var Player, step: float) =
  # controls
  if win.key(KLeft) == kaDown: player.force(vec2(-Accel, 0.0))
  if win.key(KRight) == kaDown: player.force(vec2(Accel, 0.0))

  # movement
  if win.key(KJump) == kaDown:
    if player.jumpTime > 0.0:
      player.vel.y = -JumpStrength
    player.jumpTime -= step
  else:
    player.jumpTime = 0.0

proc physics*(player: var Player, step: float) =
  player.control(step)
  player.force(Gravity)
  player.vel.x *= Decel
