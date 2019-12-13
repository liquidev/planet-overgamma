import tables

import rapid/gfx
import rdgui/button
import rdgui/control

import ../colors
import ../res

proc ButtonDock*(icon: string): ControlRenderer =
  Button.prenderer(DockImpl, button):
    if button.hasMouse:
      ctx.begin()
      ctx.color =
        if win.mouseButton(mb1) == kaDown: col"ui.button.dock.click"
        else: col"ui.button.dock.hover"
      ctx.lrrect(0, 0, button.width, button.height, 4)
      ctx.draw(prLineShape)
      ctx.color = col"base.white"
    ctx.begin()
    ctx.texture = icons[icon]
    ctx.rect(0, 0, button.width, button.height)
    ctx.draw()
    ctx.noTexture()
  result = ButtonDockImpl

proc ButtonWindow*(stroke, fill: RColor): ControlRenderer =
  Button.prenderer(WindowImpl, button):
    let
      cx = button.width / 2
      cy = button.height / 2
      cr = min(button.width, button.height) / 2
      outlineCol =
        if button.hasMouse: stroke
        else: col"ui.button.window.stroke"
      fillCol =
        if button.hasMouse:
          if win.mouseButton(mb1) == kaDown: stroke
          else: fill
        else: col"ui.button.window.fill"
    ctx.begin()
    ctx.color = fillCol
    ctx.circle(cx, cy, cr, points = 12)
    ctx.draw()
    ctx.begin()
    ctx.color = outlineCol
    ctx.lcircle(cx, cy, cr, points = 12)
    ctx.draw(prLineShape)
    ctx.color = col"base.white"

  result = ButtonWindowImpl

