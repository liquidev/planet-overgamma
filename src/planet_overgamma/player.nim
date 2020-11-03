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
    sprites: PlayerSprites
    flip: bool

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

proc update(pc: var PlayerController) =

  # controls

  const
    speed = 16
    jump = 196

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

proc shape(pr: var PlayerRenderer, graphics: Graphics, step: float32) =
  let
    sprite = pr.sprites.idle
    spriteOffset = sprite.size.vec2f - PlayerHitboxSize
  graphics.sprite(sprite, pr.body.position - spriteOffset)

proc init(pr: var PlayerRenderer, body: Body, sprites: PlayerSprites) =
  ## Initializes a player's renderer component.

  pr.body = body
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
  result.renderer.init(result.body, sprites)

  result.registerComponents()
