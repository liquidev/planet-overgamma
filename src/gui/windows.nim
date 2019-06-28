#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import lists

import rapid/gfx
import rapid/gfx/fxsurface

import ../res
import ../colors
import controls
import event
import util

#--
# Definitions
#--

type
  WindowManager* = ref object
    windows*: DoublyLinkedList[Window]
  WindowKind* = enum
    wkUndecorated
    wkDecorated
  Window* = ref object of Box
    wm*: WindowManager
    width*, height*: float
    title*: string
    kind*: WindowKind
    dragging: bool
    prevMousePos: Vec2[float]

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
  var handle = wm.windows.find(win)
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

method event*(win: Window, ev: UIEvent) =
  var ctrl = win.children.tail
  while not (ev.consumed or ctrl.isNil):
    ctrl.value.event(ev)
    ctrl = ctrl.prev
  if not ev.consumed:
    if mouseInArea(win.pos.x, win.pos.y, win.width, win.height) and
       ev.kind == evMousePress or ev.kind == evMouseRelease:
      win.dragging = ev.kind == evMousePress
      if win.dragging:
        win.wm.bringToTop(win)
        ev.consume()
    elif ev.kind == evMouseMove:
      if win.dragging:
        let delta = ev.mousePos - win.prevMousePos
        win.pos += delta
      win.prevMousePos = ev.mousePos

renderer(Window, Default, win):
  if win.kind in {wkDecorated, wkUndecorated}:
    fx.begin(ctx, copyTarget = true)

    ctx.clearStencil(0)
    stencil(ctx, saReplace, 255):
      ctx.begin()
      ctx.rrect(0, 0, win.width, win.height, 8)
      ctx.draw()

    ctx.stencilTest = (scEq, 255)
    fxBoxBlur.param("radius", 7)
    fx.effect(fxBoxBlur, stencil = true)
    fx.effect(fxBoxBlur, stencil = true)
    ctx.noStencilTest()

    fx.finish()

    ctx.begin()
    ctx.color = col.ui.window.background
    ctx.rrect(0, 0, win.width, win.height, 8)
    ctx.draw()

    ctx.begin()
    ctx.color = col.ui.window.border
    ctx.lrrect(0, 0, win.width, win.height, 8)
    ctx.draw(prLineShape)

proc initWindow*(win: Window, wm: WindowManager, x, y, width, height: float,
                 title: string, kind: WindowKind) =
  win.initBox(x, y, rend = WindowDefault)
  win.wm = wm
  win.width = width
  win.height = height
  win.title = title
  win.kind = kind

proc newWindow*(wm: WindowManager, x, y, width, height: float, title: string,
                kind: WindowKind): Window =
  new(result)
  result.initWindow(wm, x, y, width, height, title, kind)
