#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import lists

import rapid/gfx
import rapid/gfx/fxsurface
import rapid/gfx/text
import rapid/res/fonts
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
    windows*: DoublyLinkedList[Window]
  WindowKind* = enum
    wkUndecorated
    wkDecorated
    wkGame
    wkHud
  WindowObj* = object of Box
    wm*: WindowManager
    # Properties
    width*, height*: float
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
  var win = wm.windows.tail
  while not (ev.consumed or win.isNil):
    win.value.event(ev)
    win = win.prev

proc add*(wm: WindowManager, win: Window) =
  wm.windows.append(win)

proc bringToTop*(wm: WindowManager, win: Window) =
  let handle = wm.windows.find(win)
  wm.windows.remove(handle)
  wm.windows.append(handle)

proc initWindowManager*(wm: WindowManager, win: RWindow) =
  wm.windows = initDoublyLinkedList[Window]()
  win.registerEvents do (ev: UIEvent):
    wm.event(ev)

proc newWindowManager*(win: RWindow): WindowManager =
  new(result)
  result.initWindowManager(win)

#--
# Window
#--

proc close*(win: Window) =
  if win.onClose(win):
    let handle = win.wm.windows.find(win)
    win.wm.windows.remove(handle)

method event*(win: Window, ev: UIEvent) =
  case win.kind
  of wkUndecorated, wkDecorated:
    var ctrl = win.children.tail
    while not (ev.consumed or ctrl.isNil):
      ctrl.value.event(ev)
      ctrl = ctrl.prev
    if not ev.consumed:
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

      ctx.color = col.base.white
      fx.finish()

    ctx.begin()
    ctx.color = col.ui.window.background
    ctx.rrect(0, 0, win.width, win.height, 6)
    ctx.draw()

    ctx.begin()
    ctx.color = col.ui.window.border
    ctx.lrrect(0, 0, win.width, win.height, 6)
    ctx.draw(prLineShape)
    if win.kind == wkDecorated:
      let color =
        if win.mouseInCircle(14, 14, 8):
          if res.win.mouseButton(mb1) == kaDown:
            col.ui.window.buttons.close.click
          else:
            col.ui.window.buttons.close.hover
        else:
          col.ui.window.buttons.close.normal
      win.closeButtonFill =
        win.closeButtonFill.mix(color.fill, 0.4 * step)
      win.closeButtonStroke =
        win.closeButtonStroke.mix(color.stroke, 0.4 * step)
      ctx.begin()
      ctx.color = win.closeButtonFill
      ctx.circle(14, 14, 5, 13)
      ctx.draw()
      ctx.begin()
      ctx.color = win.closeButtonStroke
      ctx.lcircle(14, 14, 5, 13)
      ctx.color = col.base.white
      ctx.draw(prLineShape)
      let prevAlign = firaSansB.horzAlign
      firaSansB.horzAlign = taCenter
      ctx.text(firaSansB, 16 + (win.width - 16) / 2, 6, win.title)
      firaSansB.horzAlign = prevAlign
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

  win.closeButtonFill = col.ui.window.buttons.close.normal.fill
  win.closeButtonStroke = col.ui.window.buttons.close.normal.stroke

proc newWindow*(wm: WindowManager, x, y, width, height: float, title: string,
                kind: WindowKind): Window =
  new(result)
  result.initWindow(wm, x, y, width, height, title, kind)
