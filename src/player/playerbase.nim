#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx
import rapid/gfx/texatlas
import rapid/world/sprite

import ../res
import ../util/direction
import ../world/worldconfig
import ../colors
import playercontrol
import playerdef
import playermath

export playerdef
export playermath

# proc drawLasers(player: var Player, ctx: var RGfxContext, step: float) =


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
  # player.drawLasers(ctx, step)

method update*(player: Player, step: float) =
  player.physics(step)

proc newPlayer*(name: string): Player =
  result = Player(
    width: 8, height: 8,
    name: name
  )
  result.initControls()
