#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import lists

import rapid/gfx

import ../res
import event

#--
# Control
#--

type
  ControlRenderer* = proc (ctx: RGfxContext, step: float, ctrl: Control)
  Control* = ref object of RootObj
    parent: Control
    pos*: Vec2[float]
    renderer*: ControlRenderer

proc screenPos*(ctrl: Control): Vec2[float] =
  if ctrl.parent.isNil: ctrl.pos
  else: ctrl.parent.screenPos + ctrl.pos

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

method event*(ctrl: Control, ev: UIEvent) {.base.} =
  discard

#--
# Box
#--

type
  Box* = ref object of Control
    children*: DoublyLinkedList[Control]

renderer(Box, Children, box):
  for child in box.children:
    child.draw(ctx, step)

method event*(box: Box, ev: UIEvent) =
  var ctrl = box.children.tail
  while not (ev.consumed or ctrl.isNil):
    ctrl.value.event(ev)
    ctrl = ctrl.prev

proc initBox*(box: Box, x, y: float, rend = BoxChildren) =
  box.initControl(x, y, rend)
  box.children = initDoublyLinkedList[Control]()

proc newBox*(x, y: float, rend = BoxChildren): Box =
  result = Box()
  result.initBox(x, y, rend)

proc add*(box: Box, child: Control): Box {.discardable.} =
  result = box
  result.children.append(child)
  child.parent = box

proc bringToTop*(box: Box, child: Control) =
  let ctrl = box.children.find(child)
  box.children.remove(ctrl)
  box.children.append(ctrl)
