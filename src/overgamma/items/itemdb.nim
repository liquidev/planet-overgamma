import tables

type
  ItemDesc* = object
    name*, uiName*: string
  ItemDatabase* = ref object
    items*: Table[string, ItemDesc]

proc newItemDatabase*(): ItemDatabase =
  ## Creates an empty item database.
  new(result)

proc newItemDesc*(name, uiName: string): ItemDesc =
  ## Creates a new item descriptor.
  result.name = name
  result.uiName = uiName

