#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx/surface
import rapid/gfx/texatlas
import rapid/world/sprite

import ../res/resources
import ../util/direction
import ../world/worldconfig
import ../colors
import playercontrol
import playerdef
import playermath

export playerdef
export playermath

method draw*(player: var Player, ctx: var RGfxContext, step: float) =
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
  ctx.begin()
  ctx.color = col.player.laser.destroy
  let pos = player.scrToWld(vec2(win.mouseX, win.mouseY))
  ctx.lineWidth = WorldScale
  ctx.line((player.pos.x + 4, player.pos.y + 4), (pos.x, pos.y))
  ctx.color = col.base.white
  ctx.draw(prLineShape)

method update*(player: var Player, step: float) =
  player.physics(step)

proc newPlayer*(name: string): Player =
  result = Player(
    width: 8, height: 8,
    name: name
  )
  result.initControls()
