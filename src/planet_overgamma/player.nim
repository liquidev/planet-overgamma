## You, the player. Code related to player sprites, physics, controls, among
## other stuff.

import std/os
import std/sugar

import aglet/input as ain
import rapid/physics/simple
import rapid/graphics
import rapid/graphics/image
import rapid/input as rin
import rapid/math/interpolation

import camera
import controls
import logger
import ecext
import registry
import tiles
import world


# sprites

type
  PlayerSprites* = tuple[idle, walk, fall: Sprite]

proc loadPlayerSprites*(graphics: Graphics,
                        pathIdle, pathWalk, pathFall: string): PlayerSprites =
  ## Loads player sprites from PNG files pointer to by the given paths.

  hint "loading player sprites"
  hint "  - idle: ", pathIdle
  hint "  - walk: ", pathWalk
  hint "  - fall: ", pathFall

  result = (
    idle: graphics.addSprite(loadPngImage(pathIdle)),
    walk: graphics.addSprite(loadPngImage(pathWalk)),
    fall: graphics.addSprite(loadPngImage(pathFall)),
  )

proc loadPlayerSprites*(graphics: Graphics, commonPath: string): PlayerSprites =
  ## Loads player sprites from a common path. For example,
  ## ``player`` loads ``player_idle.png``, ``player_walk.png``, and
  ## ``player_fall.png``.

  graphics.loadPlayerSprites(
    pathIdle = addFileExt(commonPath & "_idle", "png"),
    pathWalk = addFileExt(commonPath & "_walk", "png"),
    pathFall = addFileExt(commonPath & "_fall", "png"),
  )


# components + entity

type
  PlayerController* = object of RootComponent
    body: Body
    controls: Controls
    input: Input

  LaserMode* = enum
    lmDig
    lmPlace
    lmTinker

  PlayerLaser* = object of ExtComponent
    body: Body
    input: Input
    world: World

    target: Interpolated[Vec2f]
    charge: Interpolated[float32]
    chargeSpeed, chargeMax: float32
    reach: float32
    mode: LaserMode

  PlayerRenderer* = object of ExtComponent
    body: Body
    controls: Controls
    input: Input

    sprites: PlayerSprites

    flip: bool
    walkCycleTick: uint8
    falling: bool

  Player* = ref object of RootEntity
    body*: Body
    controller*: PlayerController
    renderer*: PlayerRenderer
    laser*: PlayerLaser

const PlayerHitboxSize* = vec2f(8, 6)


# component: controller

proc resist(speed, terminalVelocity, coeffLimit: float32): float32 =

  const power = 4
  let coeff = 1 / terminalVelocity.pow(power)
  speed * max(-coeff * speed.pow(power) + 1, coeffLimit)

proc componentUpdate(pc: var PlayerController) =

  # controls

  const
    speed = 0.25
    jump = 3.5

  if pc.input.keyIsDown(pc.controls.kLeft):
    pc.body.applyForce(vec2f(-speed, 0))
  if pc.input.keyIsDown(pc.controls.kRight):
    pc.body.applyForce(vec2f(speed, 0))

  if pc.input.keyJustPressed(pc.controls.kJump) and
     pc.body.collidingWith(rsTop):
    pc.body.applyForce(vec2f(0, -jump))

  pc.body.velocity.x *= 0.8

proc init(pc: var PlayerController, body: Body,
          controls: Controls, input: Input) =
  ## Initializes a player's controller component.

  pc.body = body
  pc.controls = controls
  pc.input = input

  pc.autoImplement()


# component: renderer

proc interpolatedPosition*(pr: PlayerRenderer, step: float32): Vec2f =
  ## Returns the interpolated position of the player.
  pr.body.position.lerp(step)

const
  walkCycleLength: uint8 = 20
  halfWalkCycle: uint8 = walkCycleLength div 2

proc componentLateUpdate(pr: var PlayerRenderer, camera: var Camera) =
  # this assumes 60 tps

  pr.tickInterpolated()

  # sprite directions
  if pr.input.keyIsDown(pr.controls.kLeft):
    pr.flip = true
  if pr.input.keyIsDown(pr.controls.kRight):
    pr.flip = false

  # walking animation
  if abs(pr.body.velocity.x) > 0.2:
    inc pr.walkCycleTick
    if pr.walkCycleTick > walkCycleLength:
      pr.walkCycleTick = 0
  else:
    pr.walkCycleTick = 0

  if pr.body.velocity.y < 0:
    pr.walkCycleTick = 1
  pr.falling = pr.body.velocity.y > 0

  camera.position = pr.body.position

proc componentShape(pr: var PlayerRenderer, graphics: Graphics, step: float32) =
  let
    sprite =
      if pr.falling: pr.sprites.fall
      elif pr.walkCycleTick in 1u8..halfWalkCycle: pr.sprites.walk
      else: pr.sprites.idle
    offset = sprite.size.vec2f - PlayerHitboxSize
    position = pr.body.position.lerp(step) - offset

  graphics.transform:
    graphics.translate(position + sprite.size.vec2f / 2)
    graphics.scale(float32(not pr.flip) * 2 - 1, 1)
    graphics.sprite(sprite, -sprite.size.vec2f / 2)

proc init(pr: var PlayerRenderer, body: Body,
          controls: Controls, input: Input,
          sprites: PlayerSprites) =
  ## Initializes a player's renderer component.

  pr.body = body
  pr.controls = controls
  pr.input = input
  pr.sprites = sprites

  pr.autoImplementExt()


# component: laser

{.push inline.}

proc tileTarget(pl: PlayerLaser): Vec2i =
  floor(pl.target / pl.world.tileSize).vec2i

proc active(pl: PlayerLaser): bool =
  pl.input.mouseButtonIsDown(mbLeft) or pl.input.mouseButtonIsDown(mbRight)

proc justActivated(pl: PlayerLaser): bool =
  pl.input.mouseButtonJustPressed(mbLeft) or
  pl.input.mouseButtonJustPressed(mbRight)

{.pop.}

proc componentLateUpdate(pl: var PlayerLaser, camera: var Camera) =

  pl.tickInterpolated()

  let
    rawTarget = camera.toWorld(pl.input.mousePosition)
    distFromTargetToPlayer =
      distance(rawTarget, pl.body.position + pl.body.size / 2)
    targetDir = (rawTarget - pl.body.position) / distFromTargetToPlayer
    target =
      pl.body.position + targetDir * min(distFromTargetToPlayer, pl.reach)
  pl.target <- target

  if pl.active:
    pl.charge <-+ (pl.chargeMax - pl.charge) * pl.chargeSpeed
  else:
    pl.charge <- 0

proc componentUpdate(pl: var PlayerLaser) =

  if pl.justActivated or pl.charge > 0:
    let
      mapTile = pl.world[pl.tileTarget]
      background = pl.input.mouseButtonIsDown(mbRight)
      tile = mapTile.get(background)
    if pl.justActivated:
      pl.mode = lmDig
#         if tile.kind == tkEmpty: lmPlace
#         else: lmDig
    case pl.mode
    of lmDig:
      if tile.kind == tkBlock:
        let desc = pl.world.r.blockRegistry.get(tile.blockId)
        if pl.charge > desc.hardness:
          pl.world.destroyTile(pl.tileTarget, background)
          pl.charge <- max(0, pl.charge - desc.hardness * 2)
    of lmPlace: discard "TODO"
    of lmTinker: discard "TODO"

proc componentShape(pl: var PlayerLaser, graphics: Graphics, camera: Camera,
                    step: float32) =

  const
    laserGlowColors = [
      lmDig: hex"#EB134A",
      lmPlace: hex"#00EAFF",
      lmTinker: hex"#FFF324"
    ]
    laserCoreColor = hex"#FFFFFF"
    guideColor = hex"#FFFFFF"

  # pretty lasers
  if pl.charge > 0:
    let
      playerPosition = pl.body.position.lerp(step) + pl.body.size / 2
      target = pl.target.lerp(step)
      charge = pl.charge.lerp(step)
      laserColor = laserGlowColors[pl.mode]
    graphics.line(playerPosition, target, thickness = charge * 1.2,
                  cap = lcRound, laserColor, laserColor)
    graphics.circle(target, charge, laserColor)
    graphics.line(playerPosition, target, thickness = charge / 2,
                  cap = lcRound, laserCoreColor, laserCoreColor)
    graphics.circle(target, charge / 2, laserCoreColor)

  # guide
  let
    target =
      if pl.charge > 0: pl.target
      else: camera.toWorld(pl.input.mousePosition)
    tileTopLeft = floor(target / pl.world.tileSize) * pl.world.tileSize
    thickness = max(1 / camera.scale, pl.charge / pl.chargeMax)
  graphics.lineRectangle(tileTopLeft, pl.world.tileSize, thickness,
                         guideColor)

proc init(pl: var PlayerLaser, body: Body, input: Input, world: World) =
  ## Initializes a player's laser component.

  pl.body = body
  pl.input = input
  pl.world = world

  pl.chargeSpeed = 0.05
  pl.chargeMax = 3
  pl.reach = 48

  pl.autoImplementExt()
  pl.onLateUpdate componentLateUpdate


# entity: player

proc newPlayer*(world: World, position: Vec2f, controls: Controls,
                input: Input, sprites: PlayerSprites): Player =
  ## Creates and initializes a new player.

  new result

  result.body = newBody(PlayerHitboxSize).addTo(world.space)
  result.body.position = position

  result.controller.init(result.body, controls, input)
  result.renderer.init(result.body, controls, input, sprites)
  result.laser.init(result.body, input, world)

  result.registerComponents()
