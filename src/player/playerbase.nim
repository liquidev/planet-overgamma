#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import math

import rapid/gfx
import rapid/gfx/texatlas
import rapid/world/sprite

import ../colors
import ../util/direction
import playeraugments
import playercontrol
import playerdef
import playermath
import ../res
import ../world/worldconfig

export playeraugments
export playerdef
export playermath

proc drawLasers(player: Player, ctx: RGfxContext, step: float) =
  let
    src = player.pos + vec2(4.0)
    dest = player.scrToWld(vec2(win.mouseX, win.mouseY))
    qdest = floor(dest / 8) * 8
    dx = src.x - dest.x
    dy = src.y - dest.y
    len = sqrt(dx * dx + dy * dy)
    angle = arctan2(dest.y - src.y, dest.x - src.x)

  ctx.begin()
  ctx.color = col.player.laser.highlight
  ctx.lrect(qdest.x, qdest.y, 7, 7)
  ctx.lineWidth = 4
  ctx.draw(prLineShape)
  ctx.lineWidth = 1

  if player.laserMode != laserOff and player.laserCharge > 0:
    transform(ctx):
      ctx.translate(src.x, src.y)
      ctx.rotate(angle)
      ctx.begin()
      ctx.color =
        case player.laserMode
        of laserDestroy: col.player.laser.destroy
        of laserPlace: col.player.laser.place
        else: col.base.transparent
      ctx.rect(0, -player.laserCharge / 2, len, player.laserCharge)
      ctx.circle(len, 0, player.laserCharge * 0.75)
      ctx.color = col.player.laser.core
      ctx.rect(0, -player.laserCharge / 4, len, player.laserCharge / 2)
      ctx.circle(len, 0, player.laserCharge * 0.5)
      ctx.draw()
      ctx.color = col.base.white

method draw*(player: Player, ctx: RGfxContext, step: float) =
  ctx.begin()
  ctx.color = col.base.white
  ctx.texture = radio.tex
  transform(ctx):
    let r =
      if player.vel.y > 0.001:
        radio.atl.rect(2, 0)
      elif player.vel.y < -0.001 or player.walkTime > 10:
        radio.atl.rect(1, 0)
      else:
        radio.atl.rect(0, 0)
    ctx.translate(player.pos.x + 4, player.pos.y + 4)
    if player.facing == hdirLeft:
      ctx.scale(-1, 1)
    ctx.rect(-4, -4, 8, 8, r)
  ctx.draw()
  ctx.noTexture()
  player.drawLasers(ctx, step)

method update*(player: Player, step: float) =
  player.physics(step)

proc newPlayer*(name: string): Player =
  result = Player(
    width: 8, height: 8,
    name: name,
    augments: @[augmentBase]
  )
  result.updateAugments()
