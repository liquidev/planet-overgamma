#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import algorithm
import tables

import itemstorage

type
  ContainerFilterMode* = enum
    cfmNone
    cfmWhitelist
    cfmBlacklist
  ContainerSortMode* = enum
    csmByAmount
  Container* = ref object of ItemStorage
    items: OrderedTable[string, float]
    fUsedSpace: float
    fCapacity: float
    fFilterMode: ContainerFilterMode
    fFilter: seq[string]
    fSortMode: ContainerSortMode
    fSortOrder: SortOrder

iterator pairs*(con: Container): (string, float) =
  for id, amt in con.items:
    yield (id, amt)

method `[]`*(con: Container, id: string): float = con.items[id]
method usedSpace*(con: Container): float = con.fUsedSpace
method capacity*(con: Container): float = con.fCapacity
proc `capacity=`*(con: Container, newCap: float) =
  con.fCapacity = newCap
proc addCapacity*(con: Container, cap: float) =
  con.fCapacity += cap
proc filterMode*(con: Container): ContainerFilterMode = con.fFilterMode
proc `filterMode=`*(con: Container, fm: ContainerFilterMode) =
  con.fFilterMode = fm
proc sortMode*(con: Container): ContainerSortMode = con.fSortMode
proc `sortMode=`*(con: Container, sm: ContainerSortMode) =
  con.fSortMode = sm
proc sortOrder*(con: Container): SortOrder = con.fSortOrder
proc `sortOrder=`*(con: Container, order: SortOrder) =
  con.fSortOrder = order

proc filter*(con: Container, filter: varargs[string]) =
  con.fFilter.add(filter)

proc setFilter*(con: Container, filter: varargs[string]) =
  con.fFilter = @filter

proc sort(con: Container) =
  con.items.sort(proc (a, b: (string, float)): int =
    case con.sortMode
    of csmByAmount: cmp(a[1], b[1]),
    con.sortOrder)

proc collectGarbage(con: Container) =
  var garbage: seq[string]
  for id, v in con.items:
    if v == 0:
      garbage.add(id)
  for id in garbage:
    con.items.del(id)
  if garbage.len > 0:
    con.sort()

method store*(con: Container, id: string, amount: float): float =
  case con.filterMode
  of cfmNone: discard
  of cfmWhitelist:
    if id notin con.fFilter: return 0
  of cfmBlacklist:
    if id in con.fFilter: return 0
  result = min(con.freeSpace, amount)
  if result > 0:
    if not con.items.hasKey(id):
      con.items.add(id, result)
      con.sort()
    else:
      con.items[id] += result
    con.fUsedSpace += result

method retrieve*(con: Container, id: string, amount: float): float =
  result = min(con[id], amount)
  con.items[id] -= result
  con.fUsedSpace -= result
  con.collectGarbage()

proc newContainer*(capacity = Inf): Container =
  result = Container(fCapacity: capacity)
