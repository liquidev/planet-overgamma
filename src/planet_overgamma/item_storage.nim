## Item storage for player inventories, crates, etc.

import std/tables

import items
import registry

type
  ItemStorage* = ref object
    items: OrderedTable[ItemId, ItemStack]
    count, capacity: ItemQuantity
    dirty: bool

proc newItemStorage*(capacity: ItemQuantity): ItemStorage =
  ## Creates and initializes a new item storage with the given capacity.

  new result
  result.capacity = capacity

proc count*(storage: ItemStorage): ItemQuantity =
  ## Returns the total amount of items stored in the storage.
  storage.count

proc capacity*(storage: ItemStorage): ItemQuantity =
  ## Returns the capacity of the storage.
  storage.capacity

proc enlarge*(storage: ItemStorage, by: ItemQuantity) =
  ## Enlarges the storage by the given amount. Note that there is no inverse of
  ## this operation; that's because shrinking the storage would be unsafe as
  ## there could be more items than what the storage could hold after the
  ## shrink.
  storage.capacity += by

proc freeSpace*(storage: ItemStorage): ItemQuantity =
  ## Returns the amount of free space in the given item storage.
  storage.capacity - storage.count

proc `[]`*(storage: ItemStorage, id: ItemId): ItemQuantity =
  ## Retrieves the amount of items with the given ID stored in the storage.
  storage.items.getOrDefault(id, id.stack(0_0)).amount

proc put*(storage: ItemStorage, stack: ItemStack): ItemStack =
  ## Puts the item stack into the storage, and returns the stack of items
  ## remaining from the old stack. Note that this can be less than the amount of
  ## items the stack holds, if the storage cannot fit that many items.

  result = stack
  let amount = min(storage.freeSpace, stack.amount)
  if amount > 0_0:
    if stack.id notin storage.items:
      storage.items[stack.id] = stack.id.stack(0_0)
    storage.items[stack.id].amount += amount
    storage.count += amount
  result.amount -= amount

proc take*(storage: ItemStorage, stack: ItemStack): ItemStack =
  ## Tries to take the desired stack of items from the storage, and returns the
  ## actual stack the could be taken out of there. Note that the amount of items
  ## taken out may be less than the desired amount, if the storage doesn't
  ## contain that many items.

  result = (stack.id, storage[stack.id])
  result.amount = min(result.amount, stack.amount)
  if stack.id in storage.items:
    storage.items[stack.id].amount -= result.amount
    storage.count -= result.amount
