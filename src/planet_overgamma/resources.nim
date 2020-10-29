## Resource storage, distribution, and management.

import std/monotimes
import std/os
import std/times

import aglet
import aglet/window/glfw
import rapid/graphics
import rapid/input

import common
import logger
import tileset

type
  GameState* = enum
    gsMenu
    gsGame

  Game* = ref object
    # libraries
    aglet*: Aglet

    # basic/OS resources
    window*: Window
    graphics*: Graphics
    input*: Input

    # graphics resources
    masterTileset*: Tileset
      ## The master tileset is used when rendering the world, so it should
      ## contain all blocks, machines, and other types of tiles.

      # screw you SJWs i ain't changing this name to "mainTileset"
      # any day or night

    programPlain*: Program[Vertex]

    dpDefault*: DrawParams

    # runtime
    state*: GameState

const MasterTilesetSize* {.intdefine.} = 512
  # this should probably be turned into a setting at some point

template loadStaticProgram[T](window: Window,
                              vertex, fragment: static string): Program[T] =
  ## Creates a shader program from slurp'ed source code. ``fragment`` and
  ## ``vertex`` are paths to the files that should be slurp'ed.

  const
    vertexSource = slurp(vertex).glsl
    fragmentSource = slurp(fragment).glsl
  window.newProgram[:T](vertexSource, fragmentSource)

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
    let glfwInitTime = inMilliseconds(getMonoTime() - start).int / 1000
    if glfwInitTime > 1:
      hint "glfw taking its sweet time as always.\n   this time it took ",
           glfwInitTime, " seconds to initialize itself"

  hint "creating a graphics context"
  g.graphics = g.window.newGraphics()

  hint "loading shaders"
  template loadProgram(commonPath: static string): Program[Vertex] =
    hint "shader: ", commonPath
    const
      vert = commonPath.addFileExt("vert")
      frag = commonPath.addFileExt("frag")
    g.window.loadStaticProgram[:Vertex](vert, frag)
  g.programPlain = loadProgram("shaders/plain")

  hint "hashing up draw params"
  g.dpDefault = defaultDrawParams()

  hint "preparing input"
  g.input = g.window.newInput()

  hint "allocating graphics resources"
  g.masterTileset = g.window.newTileset(vec2i(MasterTilesetSize))
