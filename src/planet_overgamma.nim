## The main module. Welcome!
##
## If you're reading this, this probably means you're interested in the game's
## source code. Feel free to contribute bug fixes if you want to!
##
## While you're here, if you're lost, why not check out:
##
## - actually nothing atm since the game doesn't exist yet TODO fill this in
##   once i actually have some code in place


# imports

import std/json
import std/monotimes
import std/os
import std/parseopt
import std/strutils
import std/sugar
import std/tables
import std/times

import aglet
import rapid/ec
import rapid/game
import rapid/graphics
import rapid/graphics/tracers
import rapid/input
import rapid/physics/simple

import planet_overgamma/controls
import planet_overgamma/game_registry
import planet_overgamma/logger
import planet_overgamma/module
import planet_overgamma/parameters
import planet_overgamma/player
import planet_overgamma/resources
import planet_overgamma/world
import planet_overgamma/world_renderer
import planet_overgamma/world_generation

import planet_overgamma/core


# CLI

type
  CommandLine = object
    worldGen: string
    worldGenArgs: Arguments

proc parseCommandLine(cli: var CommandLine) =
  ## Parses command line params.

  for kind, key, value in getopt(commandLineParams()):
    case kind
    of cmdArgument:
      warning "Planet Overgamma doesn't accept positional CLI arguments"
    of cmdShortOption:
      warning "Planet Overgamma doesn't accept short CLI options"
    of cmdLongOption:
      case key
      of "worldGen":
        info "using world generator: ", value
        cli.worldGen = value
      of "passWorldGen":
        let
          kv = value.split('=', 1)
          typeAndName = kv[0].rsplit(':', 1)
          name = typeAndName[0]
          stringVal = kv[1]
          dataType = typeAndName[1].parseEnum[:ParameterDataType]()
          arg =
            case dataType
            of pdtInt: arg(stringVal.parseInt.int32)
            of pdtFloat: arg(stringVal.parseFloat.float32)
            of pdtString: arg(stringVal)
        info "passing argument to world generator (",
             name, ": ", dataType, " = ", stringVal, ")"
        cli.worldGenArgs[name] = arg
    of cmdEnd: doAssert false


# main

proc main() =
  ## Entry point. This is where the magic happens™
  ##
  ## I heard that putting your code in a separate main proc makes the program
  ## run faster. Well, to be honest, I don't believe that, but here's why I made
  ## ``main()`` into a separate proc anyways:
  ##
  ## Planet Overgamma uses a main proc to have better control over the lifetime
  ## of variables. It also allows me to shadow import names such as ``world``.
  ## Also, global variables bad. Distributing various game resources to separate
  ## modules by passing them as proc parameters is, in my opinion, a much
  ## cleaner way of structuring your program than having a bunch of global
  ## variables. You control which parts get which resources to play around with.
  ## You wouldn't want world generation to mess with your rendering,
  ## wouldn't you?

  info "welcome to Planet Overgamma!"

  info "parsing command line"
  var cli: CommandLine
  parseCommandLine(cli)

  # allocate global resource space on the stack
  var
    g: Game
    r: GameRegistry
    core: Module
    world: World
    player: Player
    playerSprites: PlayerSprites
    controls: Controls

  info "preparing global resources"
  new(r)
  g.load()
  core.loadCore(g, r)
  playerSprites = g.graphics.loadPlayerSprites("data/sprites/player_blue")
  controls = loadControls("data/controls.json")

  info "we're ready to rock!"

  # this code is somewhat temporary until i add a proper main menu
  # also it lets me skip over to the game rather quickly without having to
  # click through a bunch of menus so it'll stay here for the time being
  if cli.worldGen.len != 0:
    info "generating new world via request from CLI"
    let generator = r.worldGenRegistry.get(cli.worldGen).WorldGenerator
    hint "calling the world generator"
    let startTime = getMonoTime()
    world = generator.generate(g, r, cli.worldGenArgs)
    hint "world generation finished, took ",
         inMilliseconds(getMonoTime() - startTime).int / 1000, " seconds"

  if world.isNil:
    error "looks like i forgot to tell you to run the game with the " &
          "following CLI arguments:"
    error "--worldGen:Core::canon --passWorldGen:width:int=32"
    error "best regards, lqdev"
    quit(1)

  # temporary until i add game states
  hint "spawning player"
  player = world.newPlayer(world.playerSpawnPoint * world.tilemap.tileSize +
                             world.tilemap.tileSize / 2,
                           controls, g.input, playerSprites)
  world.entities.add(player)

  # run the game loop
  runGameWhile not g.window.closeRequested, updateFreq = 60, body = block:

    g.window.pollEvents proc (event: InputEvent) =
      g.input.process(event)

    update:
      # this block runs at a constant rate of 60 Hz

      resetTracers()

      world.update()

      g.input.finishTick()

    draw step:
      # this block runs as fast as possible (or synced to Vblank, aka V-sync)
      # ``step`` is the percentage between the current and next timestep
      var frame = g.window.render()
      frame.clearColor(colBlack)

      world.camera.screenSize = frame.size.vec2f
      world.camera.position = player.renderer.interpolatedPosition(step)
      world.camera.scale = 4.0
      world.updateChunks(g)
      frame.renderWorld(g, world, step)

      frame.finish()

when isMainModule: main()
