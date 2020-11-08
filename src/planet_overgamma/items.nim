## Items, item stacks, and everything alike.

import std/random

import rapid/graphics

import registry

type
  Item* = object
    ## Item descriptor.
    sprite*: Sprite

  ItemId* = RegistryId[Item]
  ItemRegistry* = Registry[Item]

proc initItem*(sprite: Sprite): Item =
  ## Creates and initializes a new item descriptor.
  Item(
    sprite: sprite,
  )

type
  ItemStack* = tuple
    ## An item stack that holds an amount of some item.
    id: ItemId
    amount: float32

  ItemDrop* = object
    ## Item drop information.
    id*: ItemId
    amount*: Slice[float32]

  ItemDrops* = seq[ItemDrop]

{.push inline.}

proc stack*(id: ItemId, amount: float32): ItemStack =
  ## Creates an ItemStack holding the given ``amount`` of ``id``.
  (id, amount)

proc drop*(id: ItemId, min, max: float32): ItemDrop =
  ## Creates an item drop that drops between ``min`` and ``max`` of ``id``.
  ItemDrop(id: id, amount: min..max)

proc drop*(id: ItemId, amount: float32): ItemDrop =
  ## Creates an item drop that drops exactly ``amount`` of ``id``.
  id.drop(amount, amount)

proc roll*(drop: ItemDrop): ItemStack =
  ## Creates an item stack through a random roll of the given item drop.

  if drop.amount.a == drop.amount.b:
    drop.id.stack(drop.amount.a)
  else:
    drop.id.stack(rand(drop.amount))

iterator roll*(drops: ItemDrops): ItemStack =
  ## Rolls all of the drops.

  for drop in drops:
    yield drop.roll()

{.push inline.}
