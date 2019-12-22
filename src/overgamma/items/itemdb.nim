import tables

type
  ItemDesc* = object
    name*, uiName*: string
  ItemDatabase* = ref object
    items*: Table[string, ItemDesc]

proc newItemDatabase*(): ItemDatabase =
  ## Creates an empty item database.
  new(result)

proc add*(db: ItemDatabase, name: string, id: ItemDesc) =
  ## Adds the given item descriptor into the database.
  db.items.add(name, id)

