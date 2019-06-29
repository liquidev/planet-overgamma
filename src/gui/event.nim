#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import sugar

import rapid/gfx
import rapid/world/sprite

type
  UIEventKind* = enum
    evMousePress
    evMouseRelease
    evMouseMove
    evMouseScroll
    evKeyPress
    evKeyRelease
    evKeyChar
  UIEvent* = ref object
    fConsumed: bool
    case kind: UIEventKind
    of evMousePress, evMouseRelease:
      mbButton: MouseButton
      mbMods: RModKeys
    of evMouseMove:
      mmPos: Vec2[float]
    of evMouseScroll:
      sPos: Vec2[float]
    of evKeyPress, evKeyRelease:
      kbKey: Key
      kbScancode: int
      kbMods: RModKeys
    of evKeyChar:
      kcRune: Rune
      kcMods: RModKeys
  UIEventHandler* = proc (event: UIEvent)

proc kind*(ev: UIEvent): UIEventKind = ev.kind
proc consumed*(ev: UIEvent): bool = ev.fConsumed

proc mouseButton*(ev: UIEvent): MouseButton = ev.mbButton
proc mousePos*(ev: UIEvent): Vec2[float] = ev.mmPos
proc scrollPos*(ev: UIEvent): Vec2[float] = ev.sPos

proc key*(ev: UIEvent): Key = ev.kbKey
proc scancode*(ev: UIEvent): int = ev.kbScancode
proc rune*(ev: UIEvent): Rune = ev.kcRune

proc modKeys*(ev: UIEvent): RModKeys =
  case ev.kind
  of evMousePress, evMouseRelease: ev.mbMods
  of evKeyPress, evKeyRelease: ev.kbMods
  of evKeyChar: ev.kcMods
  else: {}

proc consume*(ev: UIEvent) =
  ev.fConsumed = true

proc registerEvents*(win: RWindow, handler: UIEventHandler) =
  win.onMousePress do (_: RWindow, button: MouseButton, mods: RModKeys):
    handler(UIEvent(kind: evMousePress, mbButton: button, mbMods: mods))
  win.onMouseRelease do (_: RWindow, button: MouseButton, mods: RModKeys):
    handler(UIEvent(kind: evMouseRelease, mbButton: button, mbMods: mods))
  win.onCursorMove do (_: RWindow, x, y: float):
    handler(UIEvent(kind: evMouseMove, mmPos: vec2(x, y)))
  win.onScroll do (_: RWindow, x, y: float):
    handler(UIEvent(kind: evMouseScroll, sPos: vec2(x, y)))

  win.onKeyPress do (_: RWindow, key: Key, scancode: int, mods: RModKeys):
    handler(UIEvent(kind: evKeyPress, kbKey: key, kbScancode: scancode,
                    kbMods: mods))
  win.onKeyRelease do (_: RWindow, key: Key, scancode: int, mods: RModKeys):
    handler(UIEvent(kind: evKeyRelease, kbKey: key, kbScancode: scancode,
                    kbMods: mods))
  win.onChar do (_: RWindow, rune: Rune, mods: RModKeys):
    handler(UIEvent(kind: evKeyChar, kcRune: rune, kcMods: mods))

method event*(sprite: RSprite, event: UIEvent) {.base.} =
  discard
