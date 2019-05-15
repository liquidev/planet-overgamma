#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import strutils
import terminal

proc warn*(kind: string, msg: varargs[string, `$`]) =
  when not defined(nowarn):
    styledEcho(fgYellow, styleBright, align(kind, 12), " ",
               resetStyle, msg.join())

proc info*(kind: string, msg: varargs[string, `$`]) =
  when not defined(noinfo):
    styledEcho(fgBlue, styleBright, align(kind, 12), " ",
               resetStyle, msg.join())

proc verbose*(kind: string, msg: varargs[string, `$`]) =
  when not defined(noverbose):
    styledEcho(fgWhite, styleDim, align(kind, 12), " ",
               resetStyle, msg.join())
