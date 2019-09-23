#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import rapid/gfx

import ../res
import event

#--
# Control
#--

type
  ControlRenderer* = proc (ctx: RGfxContext, step: float, ctrl: Control)
  Control* = ref object of RootObj
    parent*: Control
    pos*: Vec2[float]
    renderer*: ControlRenderer

method width*(ctrl: Control): float {.base.} = 0
method height*(ctrl: Control): float {.base.} = 0

proc screenPos*(ctrl: Control): Vec2[float] =
  if ctrl.parent.isNil: ctrl.pos
  else: ctrl.parent.screenPos + ctrl.pos

proc mouse*(ctrl: Control): Vec2[float] =
  let sp = ctrl.screenPos
  result = vec2(win.mouseX - sp.x, win.mouseY - sp.y)

proc mouseInArea*(ctrl: Control, x, y, w, h: float): bool =
  let
    a = ctrl.screenPos + vec2(x, y)
    b = ctrl.screenPos + vec2(x + w, y + h)
  result = win.mouseX >= a.x and win.mouseY >= a.y and
           win.mouseX < b.x and win.mouseY < b.y

proc mouseInCircle*(ctrl: Control, x, y, r: float): bool =
  let
    sp = ctrl.screenPos
    dx = (x + sp.x) - win.mouseX
    dy = (y + sp.y) - win.mouseY
  result = dx * dx + dy * dy <= r * r

proc initControl*(ctrl: Control, x, y: float, rend: ControlRenderer) =
  ctrl.pos = vec2(x, y)
  ctrl.renderer = rend

template renderer*(T, name, varName, body) {.dirty.} =
  proc `T name`*(ctx: RGfxContext, step: float, ctrl: Control) =
    var varName = ctrl.T
    body

proc draw*(ctrl: Control, ctx: RGfxContext, step: float) =
  # don't use `ctx.transform()` here to avoid unnecessary matrix copies
  ctx.translate(ctrl.pos.x, ctrl.pos.y)
  ctrl.renderer(ctx, step, ctrl)
  ctx.translate(-ctrl.pos.x, -ctrl.pos.y)

method onEvent*(ctrl: Control, ev: UIEvent) {.base.} =
  discard

proc event*(ctrl: Control, ev: UIEvent) =
  if not ev.consumed:
    ctrl.onEvent(ev)

#--
# Box
#--

type
  Box* = ref object of Control
    children*: seq[Control]

method width*(box: Box): float =
  for child in box.children:
    let realWidth = child.pos.x + child.width
    if realWidth > result:
      result = realWidth

method height*(box: Box): float =
  for child in box.children:
    let realHeight = child.pos.y + child.height
    if realHeight > result:
      result = realHeight

renderer(Box, Children, box):
  for child in box.children:
    child.draw(ctx, step)

method onEvent*(box: Box, ev: UIEvent) =
  for i in countdown(box.children.len - 1, 0):
    box.children[i].event(ev)
    if ev.consumed:
      break

proc initBox*(box: Box, x, y: float, rend = BoxChildren) =
  box.initControl(x, y, rend)

proc newBox*(x, y: float, rend = BoxChildren): Box =
  result = Box()
  result.initBox(x, y, rend)

proc add*(box: Box, child: Control): Box {.discardable.} =
  result = box
  result.children.add(child)
  child.parent = box

proc bringToTop*(box: Box, child: Control) =
  let i = box.children.find(child)
  box.children.delete(i)
  box.children.add(child)