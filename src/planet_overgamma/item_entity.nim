## Item entity. This is how items are represented in the world.

import rapid/ec
import rapid/graphics
import rapid/physics/simple

import game_registry
import items
import registry

type
  ItemBody* = UserBody[ItemEntity]

  ItemRenderer* = object of RootComponent
    body: Body
    item: Item

  ItemController* = object of RootComponent
    # the controller doesn't actually let you "control" the items. it just
    # affects their physics so that they slow down
    body: Body

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
    position = ir.body.position + ir.body.size / 2 - size / 2
  graphics.sprite(ir.item.sprite, position, size)

proc init(ir: var ItemRenderer, body: Body, item: Item) =

  ir.body = body
  ir.item = item

  ir.onShape componentShape


# component: controller

proc componentUpdate(ir: var ItemController) =

  ir.body.velocity.x *= 0.95

proc init(ic: var ItemController, body: Body) =

  ic.body = body

  ic.onUpdate componentUpdate


# entity: item

proc newItemEntity*(space: Space, r: GameRegistry,
                    position, velocity: Vec2f,
                    stack: ItemStack): ItemEntity =
  ## Creates and initializes a new item entity.

  new result

  result.body = newBody(ItemHitboxSize).addTo(space)
  result.body.position = position
  result.body.velocity = velocity
  result.stack = stack

  result.renderer.init(result.body, r.itemRegistry.get(stack.id))
  result.controller.init(result.body)

  result.registerComponents()
