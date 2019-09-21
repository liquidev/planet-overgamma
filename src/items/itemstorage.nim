#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

## Base interface for item containers.

type
  ItemStorage* = ref object of RootObj
  ItemIterator* = iterator (): tuple[id: string, amt: float] {.closure.}

method `[]`*(s: ItemStorage, id: string): float {.base.} = discard
method iterate*(s: ItemStorage): ItemIterator {.base.} = discard
method capacity*(s: ItemStorage): float {.base.} = discard
method usedSpace*(s: ItemStorage): float {.base.} = discard

method store*(s: ItemStorage, id: string, amt: float): float {.base.} =
  discard
method retrieve*(s: ItemStorage, id: string, amt: float): float {.base.} =
  discard


proc freeSpace*(s: ItemStorage): float = s.capacity - s.usedSpace
