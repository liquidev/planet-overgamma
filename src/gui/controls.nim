#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import lists
import tables

import rapid/gfx
import rapid/gfx/text
import rapid/res/fonts

import ../colors
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
  # don't use `transform(ctx)` here to avoid unnecessary matrix copies
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

#--
# Button
#--

type
  ButtonKind* = enum
    buttonText
    buttonIcon
  ButtonOnClickProc* = proc (btn: Button)
  ButtonObj = object of Control
    width*, height*: float
    case kind*: ButtonKind
    of buttonText:
      text*: string
      font*: RFont
    of buttonIcon:
      icon*: string
    onClick*: ButtonOnClickProc
  Button* = ref ButtonObj

method event*(btn: Button, ev: UIEvent) =
  if ev.kind in {evMousePress, evMouseRelease}:
    if btn.mouseInArea(0, 0, btn.width, btn.height):
      ev.consume()
      if ev.kind == evMouseRelease: btn.onClick(btn)

renderer(Button, Normal, btn):
  ctx.begin()
  ctx.lrrect(0, 0, btn.width, btn.height, 4)
  ctx.draw(prLineShape)

renderer(Button, Dock, btn):
  if btn.mouseInArea(0, 0, btn.width, btn.height):
    ctx.begin()
    ctx.color =
      if win.mouseButton(mb1) == kaDown: col.ui.button.dock.click
      else: col.ui.button.dock.hover
    ctx.lrrect(0, 0, btn.width, btn.height, 4)
    ctx.draw(prLineShape)
    ctx.color = col.base.white
  case btn.kind
  of buttonIcon:
    ctx.begin()
    ctx.texture = icons[btn.icon]
    ctx.rect(0, 0, btn.width, btn.height)
    ctx.draw()
    ctx.noTexture()
  of buttonText:
    discard # TODO: Text buttons

proc init(btn: Button) =
  btn.onClick = proc (btn: Button) = discard

proc initButton*(btn: Button, x, y, w, h: float, text: string, font: RFont,
                 rend = ButtonNormal) =
  btn[] = ButtonObj(kind: buttonText)
  btn.initControl(x, y, rend)
  btn.width = w
  btn.height = h
  btn.text = text
  btn.font = font
  btn.init()

proc newButton*(x, y, w, h: float, text: string, font: RFont,
                rend = ButtonNormal): Button =
  new(result)
  result.initButton(x, y, w, h, text, font, rend)

proc initButton*(btn: Button, x, y, w, h: float, icon: string,
                 rend = ButtonNormal) =
  btn[] = ButtonObj(kind: buttonIcon)
  btn.initControl(x, y, rend)
  btn.width = w
  btn.height = h
  btn.icon = icon
  btn.init()

proc newButton*(x, y, w, h: float, icon: string, rend = ButtonNormal): Button =
  new(result)
  result.initButton(x, y, w, h, icon, rend)
