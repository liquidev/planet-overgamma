#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import tables

type
  InventoryFilterMode* = enum
    ifmNone
    ifmWhitelist
    ifmBlacklist
  Inventory* = ref object
    items: Table[string, float]
    fUsedSpace: float
    fCapacity: float
    fFilterMode: InventoryFilterMode
    fFilter: seq[string]

proc `[]`*(inv: Inventory, id: string): float = inv.items[id]
proc usedSpace*(inv: Inventory): float = inv.fUsedSpace
proc freeSpace*(inv: Inventory): float = inv.fCapacity - inv.fUsedSpace
proc capacity*(inv: Inventory): float = inv.fCapacity
proc `capacity=`*(inv: Inventory, newCap: float) =
  inv.fCapacity = newCap

proc `addCapacity`*(inv: Inventory, cap: float) =
  inv.fCapacity += cap

proc filterMode*(inv: Inventory): InventoryFilterMode = inv.fFilterMode
proc `filterMode=`*(inv: Inventory, fm: InventoryFilterMode) =
  inv.fFilterMode = fm

proc filter*(inv: Inventory, filter: varargs[string]) =
  inv.fFilter.add(filter)

proc setFilter*(inv: Inventory, filter: varargs[string]) =
  inv.fFilter = @filter

proc store*(inv: Inventory, id: string, amount: float): float =
  case inv.filterMode
  of ifmNone: discard
  of ifmWhitelist:
    if id notin inv.fFilter: return 0
  of ifmBlacklist:
    if id in inv.fFilter: return 0
  if not inv.items.hasKey(id): inv.items.add(id, 0)
  result = min(inv.freeSpace, amount)
  inv.items[id] += result
  inv.fUsedSpace += result

proc retrieve*(inv: Inventory, id: string, amount: float): float =
  result = min(inv[id], amount)
  inv.items[id] -= result
  inv.fUsedSpace -= result

proc newInventory*(capacity = Inf): Inventory =
  result = Inventory(fCapacity: capacity)
