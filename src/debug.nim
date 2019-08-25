#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import strutils
import terminal

proc warn*(kind: string, msg: varargs[string, `$`]) =
  when not defined(nowarn):
    stderr.styledWriteLine(fgYellow, styleBright, align(kind, 12), " ",
                           resetStyle, msg.join())

proc info*(kind: string, msg: varargs[string, `$`]) =
  when not defined(noinfo):
    stderr.styledWriteLine(fgBlue, styleBright, align(kind, 12), " ",
                           resetStyle, msg.join())

proc verbose*(kind: string, msg: varargs[string, `$`]) =
  when not defined(noverbose):
    stderr.styledWriteLine(fgWhite, styleDim, align(kind, 12), " ",
                           resetStyle, msg.join())
