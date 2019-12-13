import rapid/gfx
import rapid/gfx/fxsurface
import rapid/gfx/text
import rapid/world/sprite
import rdgui/button
import rdgui/control
import rdgui/event
import rdgui/windows

import ../colors
import ../gui/pobutton
import ../res
import ../world/world

#--
# Render utilities
#--

proc glass*(ctx: RGfxContext, x, y, width, height: float) = 
  if settings.graphics.blurBehindUI:
    fx.begin(ctx, copyTarget = true)

    ctx.clearStencil(0)
    ctx.stencil(saReplace, 255):
      ctx.begin()
      ctx.rrect(x, y, width, height, 6)
      ctx.draw()

    ctx.stencilTest = (scEq, 255)
    fxBoxBlur.param("radius", 7)
    fx.effect(fxBoxBlur, stencil = true)
    fx.effect(fxBoxBlur, stencil = true)
    ctx.noStencilTest()

    ctx.color = col"base.white"
    fx.finish()

  ctx.begin()
  ctx.color = col"ui.window.background"
  ctx.rrect(x, y, width, height, 6)
  ctx.draw()

  ctx.begin()
  ctx.color = col"ui.window.border"
  ctx.lrrect(x, y, width, height, 6)
  ctx.draw(prLineShape)

#--
# Game window
#--

type
  GameWindow* = ref object of Window
    gameWorld*: World

method event*(sprite: RSprite, ev: UIEvent) {.base.} =
  discard

method onEvent*(window: GameWindow, ev: UIEvent) =
  for sprite in window.gameWorld:
    sprite.event(ev)

GameWindow.renderer(Default, window):
  ctx.drawWorld(window.gameWorld, step)

proc initGameWindow*(window: GameWindow, wm: WindowManager) =
  window.initWindow(wm, 0, 0, 0, 0, GameWindowDefault)

proc newGameWindow*(wm: WindowManager): GameWindow =
  new(result)
  result.initGameWindow(wm)

#--
# Window renderers
#--

Window.renderer(Dock, window):
  ctx.glass(0, 0, window.width, window.height)
  BoxChildren(ctx, step, ctrl)

proc newDockWindow*(wm: WindowManager, x, y, width, height: float): Window =
  result = wm.newWindow(x, y, width, height, WindowDock)

proc FloatingWindowUser*(title: string): ControlRenderer =
  FloatingWindow.prenderer(UserImpl, window):
    ctx.glass(0, 0, window.width, window.height)
    ctx.text(firaSansB, 0, 0, title, w = window.width, h = 24,
             hAlign = taCenter, vAlign = taMiddle)
    BoxChildren(ctx, step, ctrl)
  result = FloatingWindowUserImpl

proc initUserWindow*(window: FloatingWindow, wm: WindowManager,
                     x, y, width, height: float,
                     title: string, closeable = true) =
  window.initFloatingWindow(wm, x, y, width, height, FloatingWindowUser(title))
  if closeable:
    let
      stroke = col"ui.window.buttons.close.stroke"
      fill = col"ui.window.buttons.close.fill"
    var closeButton = newButton(8, 8, 10, 10, ButtonWindow(stroke, fill))
    closeButton.onClick = proc () =
      window.close() # TODO: hide instead of closing
    window.add(closeButton)

proc newUserWindow*(wm: WindowManager, x, y, width, height: float,
                    title: string, closeable = true): FloatingWindow =
  new(result)
  result.initUserWindow(wm, x, y, width, height, title, closeable)

