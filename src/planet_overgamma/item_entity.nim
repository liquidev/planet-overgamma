## Item entity. This is how items are represented in the world.

import rapid/ec
import rapid/graphics
import rapid/math/interpolation
import rapid/physics/simple

import game_registry
import items
import registry

type
  ItemBody* = UserBody[ItemEntity]

  ItemRenderer* = object of RootComponent
    body: Body
    item: Item
    stack: ptr ItemStack

  ItemController* = object of RootComponent
    # the controller doesn't actually let you "control" the items. it just
    # affects their physics so that they slow down
    body: Body
    stack: ptr ItemStack

  ItemEntity* = ref object of RootEntity
    body*: Body
    stack*: ItemStack
    renderer: ItemRenderer
    controller: ItemController

const ItemHitboxSize* = vec2f(4, 4)


# component: renderer

proc componentShape(ir: var ItemRenderer, graphics: Graphics, step: float32) =

  let
    size = ir.item.sprite.size.vec2f
    count = min(3, ir.stack.amount div 10)
    position = ir.body.position.lerp(step) + ir.body.size / 2 - size / 2
  case count
  of 0: discard
  of 1:
    graphics.sprite(ir.item.sprite, position, size)
  of 2:
    graphics.sprite(ir.item.sprite, position + vec2f(0.5, -0.5), size)
    graphics.sprite(ir.item.sprite, position + vec2f(-0.5, 0.5), size)
  else:
    graphics.sprite(ir.item.sprite, position + vec2f(1, -1), size)
    graphics.sprite(ir.item.sprite, position, size)
    graphics.sprite(ir.item.sprite, position + vec2f(-1, 1), size)

proc init(ir: var ItemRenderer, body: Body, item: Item, stack: ptr ItemStack) =

  ir.body = body
  ir.item = item
  ir.stack = stack

  ir.onShape componentShape


# component: controller

proc componentUpdate(ic: var ItemController) =

  if ic.stack.amount == 0:
    ic.body.delete()
    ic.deleteEntity()

  ic.body.velocity.x *= 0.95

proc init(ic: var ItemController, body: Body, stack: ptr ItemStack) =

  ic.body = body
  ic.stack = stack

  body.onCollideWithBody proc (body, other: Body) =
    let entity = body.ItemBody.user
    if other of ItemBody:
      let otherEntity = other.ItemBody.user
      if entity.stack.id == otherEntity.stack.id:
        entity.stack.amount += otherEntity.stack.amount
        otherEntity.stack.amount = 0

  ic.onUpdate componentUpdate


# entity: item

proc newItemEntity*(space: Space, r: GameRegistry,
                    position, velocity: Vec2f,
                    stack: ItemStack): ItemEntity =
  ## Creates and initializes a new item entity.

  new result

  result.body = newBody(ItemHitboxSize, density = 1.0, result).addTo(space)
  result.body.position = position
  result.body.velocity = velocity
  result.body.elasticity = 0.4
  result.stack = stack

  result.renderer.init(result.body, r.itemRegistry.get(stack.id),
                       addr result.stack)
  result.controller.init(result.body, addr result.stack)

  result.registerComponents()
