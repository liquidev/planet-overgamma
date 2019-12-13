import math

import rapid/gfx
import rapid/world/sprite
import rdgui/event

import ../util/direction
import ../math/extramath
import ../items/container
import ../world/worldconfig
import ../world/worldinteract
import ../items/worlditem
import ../res
import playerdef
import playermath
import playerui

const
  KLeft = keyA
  KRight = keyD
  KJump = keySpace
  KOpenInventory = keyI

proc itemPopup*(player: Player, id: string, amount: float) =
  const PopupTime = 150.0
  for popup in mitems(player.itemPopups):
    if popup.id == id:
      popup.amt += amount
      popup.time = PopupTime
      return
  player.itemPopups.add((id, amount, PopupTime))

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
        of mb2:
          if player.recipe != nil: laserPlace
          else: laserOff
        else: laserOff
      else: laserOff

proc control(player: Player, step: float) =
  block controls:
    if player.movingLeft:
      player.force(vec2(-player.accel, 0.0))
      player.facing = hdirLeft
    if player.movingRight:
      player.force(vec2(player.accel, 0.0))
      player.facing = hdirRight

  block movement:
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

  block laser:
    # Charge
    let l = distance(player.pos, player.scrToWld(vec2(win.mouseX, win.mouseY)))
    if l > player.laserMaxReach:
      player.laserCharge = 0
    else:
      if player.laserMode != laserOff:
        player.laserCharge += player.laserChargeSpeed
        player.laserCharge = player.laserCharge.clamp(0, player.laserChargeMax)
      else:
        player.laserCharge = 0
    # Modes
    if player.laserCharge == player.laserChargeMax:
      let aim = floor(player.scrToWld(vec2(win.mouseX, win.mouseY)) / 8)
      case player.laserMode
      of laserDestroy:
        player.laserCharge -=
          player.world.destroy(aim.x.int, aim.y.int, player.laserCharge)
      of laserPlace:
        discard
      of laserOff: discard

method collideSprite*(player: Player, sprite: RSprite) =
  if sprite of Item:
    var item = sprite.Item
    let amount = player.inventory.store(item.id, item.count)
    item.count -= amount
    player.itemPopup(item.id, amount)

proc itemMagnet(player: Player) =
  for spr in player.world.sprites:
    if spr of Item:
      let
        dir = arctan2(player.pos.y - spr.pos.y,
                      player.pos.x - spr.pos.x)
        force = clamp(32 - distance(player.pos, spr.pos), 0, 0.12)
      spr.force(vec2(cos(dir) * force, sin(dir) * force))

proc physics*(player: Player, step: float) =
  player.control(step)

  player.force(Gravity)
  player.vel.x *= player.decel

  player.itemMagnet()
