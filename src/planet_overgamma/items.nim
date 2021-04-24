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
  ItemQuantity* = Natural
    ## Item quantities are represented as fixed-point integers with one decimal
    ## place of precision.
    ## How much this actually is varies depending on the item, but for blocks
    ## 1 = 1 block, for metals 10 = 1 bar (this is still displayed
    ## as 1 in-game).
    ##
    ## From a game design perspective, this is done mainly for easier item
    ## management as compared to splitting metals to nuggets, bars, and blocks,
    ## like Minecraft does, and also just looking nicer. Why would 10 gold mean
    ## one bar of gold? Just make it 1 gold and represent fractions of the bar
    ## as actual fractions, not ones.
    # development note: in code, represent item quantities as wholes_fractions,
    # eg. one bar = 1_0, one tenth of a bar = 0_1.

  ItemStack* = tuple
    ## An item stack that holds an amount of some item.
    id: ItemId
    amount: ItemQuantity

  ItemDrop* = object
    ## Item drop information.
    id*: ItemId
    amount*: Slice[ItemQuantity]

  ItemDrops* = seq[ItemDrop]

{.push inline.}

proc itemQuantityToString*(q: ItemQuantity): string =
  ## Stringifies an item quantity.
  let
    fractional = q mod 10
    integral = q div 10
  if fractional > 0:
    result.add($integral)
    result.add('.')
    result.add($fractional)
  else:
    result = $integral

proc stack*(id: ItemId, amount: ItemQuantity): ItemStack =
  ## Creates an ItemStack holding the given ``amount`` of ``id``.
  (id, amount)

proc drop*(id: ItemId, min, max: ItemQuantity): ItemDrop =
  ## Creates an item drop that drops between ``min`` and ``max`` of ``id``.
  ItemDrop(id: id, amount: min..max)

proc drop*(id: ItemId, amount: ItemQuantity): ItemDrop =
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

{.pop.}
