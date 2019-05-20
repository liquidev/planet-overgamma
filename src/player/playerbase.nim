#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx/surface
import rapid/world/sprite

import ../colors
import playercontrol
import playerdef

export playerdef

method draw*(player: var Player, ctx: var RGfxContext, step: float) =
  ctx.begin()
  ctx.color = col.base.white
  ctx.rect(player.pos.x, player.pos.y, 8, 8)
  ctx.draw()

method update*(player: var Player, step: float) =
  player.physics(step)

proc newPlayer*(name: string): Player =
  result = Player(
    width: 8, height: 8,
    name: name
  )
  result.initControls()
