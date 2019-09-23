#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import unicode

import rapid/gfx/text
import rapid/gfx

import ../math/extramath
import ../colors
import ../res
import control
import event

type
  TextBox* = ref object of Control
    fWidth: float
    fText: seq[Rune]
    textString: string
    caret: int
    blinkTimer: float
    focused*: bool
    next*: TextBox
    fontSize*: int
    placeholder*: string
    onInput*: proc ()

method width*(tb: TextBox): float = tb.fWidth
method height*(tb: TextBox): float =
  tb.fontSize.float * firaSans.lineSpacing + 1
proc `width=`*(tb: TextBox, width: float) =
  tb.fWidth = width

proc text*(tb: TextBox): string = tb.textString
proc `text=`*(tb: TextBox, text: string) =
  tb.fText = text.toRunes
  tb.textString = text

proc resetBlink(tb: TextBox) =
  tb.blinkTimer = time()

proc canBackspace(tb: TextBox): bool = tb.caret in 1..tb.fText.len
proc canDelete(tb: TextBox): bool = tb.caret in 0..<tb.fText.len

method onEvent*(tb: TextBox, ev: UIEvent) =
  if ev.kind == evMousePress:
    tb.focused = tb.mouseInArea(0, 0, tb.width, tb.height)
    if tb.focused:
      tb.resetBlink()
  elif tb.focused and ev.kind in {evKeyChar, evKeyPress, evKeyRepeat}:
    case ev.kind
    of evKeyChar:
      tb.fText.insert(ev.rune, tb.caret)
      inc(tb.caret)
    of evKeyPress, evKeyRepeat:
      case ev.key
      of keyBackspace:
        if tb.canBackspace:
          dec(tb.caret)
          tb.fText.delete(tb.caret)
      of keyDelete:
        if tb.canDelete:
          tb.fText.delete(tb.caret)
      of keyLeft:
        if tb.canBackspace:
          dec(tb.caret)
      of keyRight:
        if tb.canDelete:
          inc(tb.caret)
      else: discard
    else: discard
    tb.textString = $tb.fText
    tb.resetBlink()
    ev.consume()
    tb.onInput()


renderer(TextBox, Normal, tb):
  ctx.begin()
  ctx.color =
    if tb.focused: col"ui.textbox.focused"
    else: col"ui.textbox.normal"
  ctx.line((0.0, tb.height + 1), (tb.width, tb.height + 1))
  ctx.color = col"base.white"
  ctx.draw(prLineShape)

  firaSans.height = tb.fontSize
  if tb.fText.len < 1:
    ctx.color = col"ui.textbox.placeholder"
    ctx.text(firaSans, 0, 0, tb.placeholder)

  ctx.color = col"ui.textbox.text"
  ctx.text(firaSans, 0, 0, tb.fText)
  ctx.color = col"base.white"

  if tb.focused and floorMod(time() - tb.blinkTimer, 1.0) < 0.5:
    ctx.begin()
    ctx.color = col"ui.textbox.caret"
    var x = 0.0
    for r in 0..<tb.caret:
      x += firaSans.widthOf(tb.fText[r])
    ctx.line((x, 0.0), (x, tb.fontSize.float * firaSans.lineSpacing))
    ctx.color = col"base.white"
    ctx.draw(prLineShape)

  firaSans.height = 14

proc initTextBox*(tb: TextBox, x, y, w: float, placeholder, text = "",
                  fontSize = 14, prev: TextBox = nil, rend = TextBoxNormal) =
  tb.initControl(x, y, rend)
  tb.width = w
  tb.text = text
  tb.placeholder = placeholder
  tb.fontSize = fontSize
  if prev != nil:
    prev.next = tb
  tb.onInput = proc () = discard

proc newTextBox*(x, y, w: float, placeholder, text = "", fontSize = 14,
                 prev: TextBox = nil, rend = TextBoxNormal): TextBox =
  result = TextBox()
  result.initTextBox(x, y, w, placeholder, text, fontSize, prev, rend)
