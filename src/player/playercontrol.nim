#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx
import rapid/world/sprite

import ../util/direction
import ../gui/event
import playerdef
import ../res

const
  Gravity = vec2(0.0, 0.10)
  KLeft = keyA
  KRight = keyD
  KJump = keySpace

method event*(player: Player, event: UIEvent) =
  if event.kind in {evKeyPress, evKeyRelease}:
    if event.key == KLeft:
      player.movingLeft = event.kind == evKeyPress
    elif event.key == KRight:
      player.movingRight = event.kind == evKeyPress
    elif event.key == KJump:
      player.jumping = event.kind == evKeyPress
      if player.jumping and player.vel.y == 0.0:
        player.jumpTime = player.jumpSustainTime
    else: return
    event.consume()
  elif event.kind in {evMousePress, evMouseRelease}:
    player.laserMode =
      if event.kind == evMousePress:
        case event.mouseButton
        of mb1: laserDestroy
        of mb2: laserPlace
        else: laserOff
      else: laserOff

proc control(player: Player, step: float) =
  # controls
  if player.movingLeft:
    player.force(vec2(-player.accel, 0.0))
    player.facing = hdirLeft
  if player.movingRight:
    player.force(vec2(player.accel, 0.0))
    player.facing = hdirRight

  # movement
  if player.jumping:
    if player.jumpTime > 0.0:
      player.vel.y = -player.jumpStrength
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
  player.vel.x *= player.decel
