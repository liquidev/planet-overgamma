## The main module.

import aglet
import rapid/game
import rapid/graphics
import rapid/input

import planet_overgamma/game_registry
import planet_overgamma/logger
import planet_overgamma/module
import planet_overgamma/resources
import planet_overgamma/tiles
import planet_overgamma/world

import planet_overgamma/core

proc main() =
  ## Entry point. Welcome!
  ##
  ## If you're reading this, this probably means you're interested in the game's
  ## source code. Feel free to contribute bug fixes if you want to!
  ##
  ## While you're here, if you're lost, why not check out:
  ##
  ## - actually nothing atm since the game doesn't exist yet TODO fill this in
  ##   once i actually have some code in place

  info "welcome to Planet Overgamma!"

  # allocate global resource space on the stack
  var
    g: Game
    r: GameRegistry
    core: Module
    world: World

  info "preparing global resources"
  new(r)
  g.load()
  core.loadCore(g, r)

  info "we're ready to rock!"

  # run the game loop
  runGameWhile not g.window.closeRequested:

    g.window.pollEvents proc (event: InputEvent) =
      g.input.process(event)

    update:
      # this block runs at a constant rate of 60 Hz
      if g.input.keyJustPressed(keySpace):
        echo "spacing out"
      g.input.finishTick()

    draw step:
      # this block runs as fast as possible (or synced to Vblank, aka V-sync)
      # ``step`` is the percentage between the current and next timestep
      var frame = g.window.render()
      frame.clearColor(colBlack)
      frame.finish()

when isMainModule: main()
