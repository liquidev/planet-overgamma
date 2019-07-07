#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import strutils
import tables

import rapid/gfx
import rapid/gfx/text
import rapid/res/fonts

import ../gui/controls
import ../res
import playerdef
import playermath

type
  PlayerHud* = ref object of Control
    player: Player

renderer(PlayerHud, Default, hud):
  block itemPopups:
    var width, y = 0.0
    for popup in hud.player.itemPopups:
      let popupWidth = 28 + firaSans14.widthOf(popup.amt.itemAmtStr)
      if width < popupWidth:
        width = popupWidth
    let
      baseX = win.width / 2 - width / 2
      baseY = win.height / 2
    ctx.begin()
    ctx.texture = itemSprites
    for popup in hud.player.itemPopups:
      ctx.rect(baseX, baseY - y - 42, 24, 24, itemSpriteData[popup.id])
      y += 32
    ctx.draw()
    ctx.noTexture()
    y = 0
    for popup in hud.player.itemPopups:
      ctx.text(firaSans14, baseX + 28, baseY - y - 36, popup.amt.itemAmtStr)
      y += 32

proc newPlayerHud*(player: Player): PlayerHud =
  result = PlayerHud(player: player, renderer: PlayerHudDefault)
