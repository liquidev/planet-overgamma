import tables

import rapid/gfx
import rdgui/control

import ../res
import playerdef

type
  AssemblerKind* = enum
    akPortable
    akMachine
  AssemblerViewObj = object of Control
    case kind: AssemblerKind
    of akPortable:
      player: Player
    of akMachine:
      discard
  AssemblerView* = ref AssemblerViewObj

AssemblerView.renderer(Default, view):
  var y = 0
  for name, recipe in recipes.blocks:
    ctx.begin()
    ctx.lrect(0, y.float, 32, 32)
    ctx.draw(prLineShape)

proc initAssemblerView*(view: AssemblerView, x, y: float, player: Player,
                        rend = AssemblerViewDefault) =
  view[] = AssemblerViewObj(kind: akPortable)
  view.initControl(x, y, rend)
  view.player = player

proc newAssemblerView*(x, y: float, player: Player,
                       rend = AssemblerViewDefault): AssemblerView =
  new(result)
  result.initAssemblerView(x, y, player, rend)
