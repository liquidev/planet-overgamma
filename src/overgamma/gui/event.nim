#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import unicode

import rapid/gfx
import rapid/world/sprite

type
  UIEventKind* = enum
    evMousePress
    evMouseRelease
    evMouseMove
    evMouseScroll
    evKeyPress
    evKeyRepeat
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
    of evKeyPress, evKeyRepeat, evKeyRelease:
      kbKey: Key
      kbScancode: int
      kbMods: RModKeys
    of evKeyChar:
      kcRune: Rune
      kcMods: RModKeys
  UIEventHandler* = proc (event: UIEvent)

proc `$`*(ev: UIEvent): string =
  result = $ev.kind & ' ' & (
    case ev.kind
    of evMousePress, evMouseRelease: $ev.mbButton & " + " & $ev.mbMods
    of evMouseMove: $ev.mmPos
    of evMouseScroll: $ev.sPos
    of evKeyPress, evKeyRepeat, evKeyRelease:
      $ev.kbKey & " (" & $ev.kbScancode & ") + " & $ev.kbMods
    of evKeyChar: $ev.kcRune.int & " `" & $ev.kcRune & "` + " & $ev.kcMods
  )
  result.add(" - consumed: " & $ev.fConsumed)

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
  win.onMousePress do (button: MouseButton, mods: RModKeys):
    handler(UIEvent(kind: evMousePress, mbButton: button, mbMods: mods))
  win.onMouseRelease do (button: MouseButton, mods: RModKeys):
    handler(UIEvent(kind: evMouseRelease, mbButton: button, mbMods: mods))
  win.onCursorMove do (x, y: float):
    handler(UIEvent(kind: evMouseMove, mmPos: vec2(x, y)))
  win.onScroll do (x, y: float):
    handler(UIEvent(kind: evMouseScroll, sPos: vec2(x, y)))

  win.onKeyPress do (key: Key, scancode: int, mods: RModKeys):
    handler(UIEvent(kind: evKeyPress, kbKey: key, kbScancode: scancode,
                    kbMods: mods))
  win.onKeyRepeat do (key: Key, scancode: int, mods: RModKeys):
    handler(UIEvent(kind: evKeyRepeat, kbKey: key, kbScancode: scancode,
                    kbMods: mods))
  win.onKeyRelease do (key: Key, scancode: int, mods: RModKeys):
    handler(UIEvent(kind: evKeyRelease, kbKey: key, kbScancode: scancode,
                    kbMods: mods))
  win.onChar do (rune: Rune, mods: RModKeys):
    handler(UIEvent(kind: evKeyChar, kcRune: rune, kcMods: mods))

method event*(sprite: RSprite, event: UIEvent) {.base.} =
  discard