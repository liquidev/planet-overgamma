## Resource storage, distribution, and management.

import std/monotimes
import std/times

import aglet
import aglet/window/glfw
import rapid/graphics
import rapid/input

import logger
import tileset

type
  Game* = ref object
    aglet*: Aglet

    window*: Window
    graphics*: Graphics
    input*: Input

proc load*(g: var Game) =
  ## Loads/allocates all basic resources (window, graphics context, effect
  ## buffers, etc.) into the given Game object.

  info "hi load()"
  new g

  hint "initializing aglet"
  g.aglet = initAglet()
  g.aglet.initWindow()

  hint "opening window"
  block:
    let start = getMonoTime()
    g.window = g.aglet.newWindowGlfw(
      width = 1024, height = 768,
      title = "Planet Overgamma 2: Electric Boogaloo",
      hints = winHints(),
    )
    hint "glfw taking its sweet time as always.\n   this time it took ",
         inMilliseconds(getMonoTime() - start).int / 1000,
         " seconds to open the window"

  hint "creating a graphics context"
  g.graphics = g.window.newGraphics()

  hint "preparing input"
  g.input = g.window.newInput()
