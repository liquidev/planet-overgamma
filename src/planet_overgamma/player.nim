## You, the player. Code related to player sprites, physics, controls, among
## other stuff.

import std/os

import rapid/ec
import rapid/physics/simple
import rapid/graphics
import rapid/graphics/image
import rapid/input

import controls


# sprites

type
  PlayerSprites* = tuple[idle, walk, fall: Sprite]

proc loadPlayerSprites*(graphics: Graphics,
                        pathIdle, pathWalk, pathFall: string): PlayerSprites =
  ## Loads player sprites from PNG files pointer to by the given paths.

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

  PlayerRenderer* = object of RootComponent
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
  pr.body.position

const
  walkCycleLength: uint8 = 20
  halfWalkCycle: uint8 = walkCycleLength div 2

proc componentUpdate(pr: var PlayerRenderer) =
  # this assumes 60 tps

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

proc componentShape(pr: var PlayerRenderer, graphics: Graphics, step: float32) =
  let
    sprite =
      if pr.falling: pr.sprites.fall
      elif pr.walkCycleTick in 1u8..halfWalkCycle: pr.sprites.walk
      else: pr.sprites.idle
    offset = sprite.size.vec2f - PlayerHitboxSize
    position = pr.body.position - offset
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

  pr.autoImplement()


# entity: player

proc newPlayer*(space: Space, position: Vec2f, controls: Controls,
                input: Input, sprites: PlayerSprites): Player =
  ## Creates and initializes a new player.

  new result

  result.body = newBody(PlayerHitboxSize).addTo(space)
  result.body.position = position

  result.controller.init(result.body, controls, input)
  result.renderer.init(result.body, controls, input, sprites)

  result.registerComponents()
