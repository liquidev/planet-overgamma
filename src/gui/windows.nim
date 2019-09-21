#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx
import rapid/gfx/fxsurface
import rapid/gfx/text
import rapid/world/tilemap

import ../world/world
import ../colors
import ../res
import control
import event

#--
# Definitions
#--

type
  WindowManager* = ref object
    windows*: seq[Window]
  WindowKind* = enum
    wkUndecorated
    wkDecorated
    wkGame
    wkHud
  WindowObj* = object of Box
    wm*: WindowManager
    # Properties
    fWidth, fHeight: float
    title*: string
    case kind*: WindowKind
    of wkGame:
      gameWorld*: World
    else: discard
    # Interaction
    draggable*: bool
    dragging: bool
    prevMousePos: Vec2[float]
    closeButtonFill, closeButtonStroke: RColor
    # Callbacks
    onClose*: proc (win: Window): bool
  Window* = ref WindowObj

#--
# WM
#--

proc draw*(wm: WindowManager, ctx: RGfxContext, step: float) =
  for win in wm.windows:
    win.draw(ctx, step)

proc event*(wm: WindowManager, ev: UIEvent) =
  for i in countdown(wm.windows.len - 1, 0):
    wm.windows[i].event(ev)
    if ev.consumed:
      break

proc add*(wm: WindowManager, win: Window) =
  wm.windows.add(win)

proc bringToTop*(wm: WindowManager, win: Window) =
  let i = wm.windows.find(win)
  wm.windows.delete(i)
  wm.windows.add(win)

proc initWindowManager*(wm: WindowManager, win: RWindow) =
  win.registerEvents do (ev: UIEvent):
    wm.event(ev)

proc newWindowManager*(win: RWindow): WindowManager =
  new(result)
  result.initWindowManager(win)

#--
# Window
#--

method width*(win: Window): float = win.fWidth
method height*(win: Window): float = win.fHeight
proc `width=`*(win: Window, width: float) =
  win.fWidth = width
proc `height=`*(win: Window, height: float) =
  win.fHeight = height

proc close*(win: Window) =
  if win.onClose == nil or win.onClose(win):
    let handle = win.wm.windows.find(win)
    win.wm.windows.delete(handle)

method event*(win: Window, ev: UIEvent) =
  case win.kind
  of wkUndecorated, wkDecorated:
    for i in countdown(win.children.len - 1, 0):
      win.children[i].event(ev)
      if ev.consumed:
        return
    if win.draggable and
       win.mouseInArea(0, 0, win.width, win.height) and
       ev.kind == evMousePress or ev.kind == evMouseRelease:
      win.dragging = ev.kind == evMousePress
      if win.dragging:
        win.wm.bringToTop(win)
        ev.consume()
      if win.kind == wkDecorated and ev.kind == evMouseRelease and
         win.mouseInCircle(14, 14, 8):
        win.close()
        ev.consume()
    elif ev.kind == evMouseMove:
      if win.dragging:
        let delta = ev.mousePos - win.prevMousePos
        win.pos += delta
        win.pos.x = clamp(win.pos.x, 0, res.win.width.float - win.width)
        win.pos.y = clamp(win.pos.y, 0, res.win.height.float - win.height)
      win.prevMousePos = ev.mousePos
  of wkGame:
    for spr in win.gameWorld:
      spr.event(ev)
  of wkHud: discard

renderer(Window, Default, win):
  case win.kind
  of wkUndecorated, wkDecorated:
    if settings.graphics.blurBehindUI:
      fx.begin(ctx, copyTarget = true)

      ctx.clearStencil(0)
      ctx.stencil(saReplace, 255):
        ctx.begin()
        ctx.rrect(0, 0, win.width, win.height, 6)
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
    ctx.rrect(0, 0, win.width, win.height, 6)
    ctx.draw()

    ctx.begin()
    ctx.color = col"ui.window.border"
    ctx.lrrect(0, 0, win.width, win.height, 6)
    ctx.draw(prLineShape)
    if win.kind == wkDecorated:
      let color =
        if win.mouseInCircle(14, 14, 8):
          if res.win.mouseButton(mb1) == kaDown:
            "ui.window.buttons.close.click"
          else:
            "ui.window.buttons.close.hover"
        else:
          "ui.window.buttons.close.normal"
      win.closeButtonFill =
        win.closeButtonFill.mix(col(color & ".fill"), 0.4 * step)
      win.closeButtonStroke =
        win.closeButtonStroke.mix(col(color & ".stroke"), 0.4 * step)
      ctx.begin()
      ctx.color = win.closeButtonFill
      ctx.circle(14, 14, 5, 13)
      ctx.draw()
      ctx.begin()
      ctx.color = win.closeButtonStroke
      ctx.lcircle(14, 14, 5, 13)
      ctx.color = col"base.white"
      ctx.draw(prLineShape)
      ctx.text(firaSansB, 16 + (win.width - 16) / 2, 6, win.title,
               hAlign = taCenter)
    for ctrl in win.children:
      ctrl.draw(ctx, step)
  of wkGame:
    ctx.lineSmooth = false
    win.gameWorld.draw(ctx, step)
    ctx.lineSmooth = true
  of wkHud:
    for ctrl in win.children:
      ctrl.draw(ctx, step)

proc initWindow*(win: Window, wm: WindowManager, x, y, width, height: float,
                 title: string, kind: WindowKind) =
  win[] = WindowObj(kind: kind)
  win.initBox(x, y, rend = WindowDefault)
  win.wm = wm
  win.width = width
  win.height = height
  win.title = title
  win.draggable = true

  win.closeButtonFill = col"ui.window.buttons.close.normal.fill"
  win.closeButtonStroke = col"ui.window.buttons.close.normal.stroke"

proc newWindow*(wm: WindowManager, x, y, width, height: float, title: string,
                kind: WindowKind): Window =
  new(result)
  result.initWindow(wm, x, y, width, height, title, kind)
