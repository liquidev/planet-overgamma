#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import tables

import rapid/gfx
import rapid/res/fonts

import ../colors
import ../res
import control
import event

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
      if win.mouseButton(mb1) == kaDown: col"ui.button.dock.click"
      else: col"ui.button.dock.hover"
    ctx.lrrect(0, 0, btn.width, btn.height, 4)
    ctx.draw(prLineShape)
    ctx.color = col"base.white"
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
