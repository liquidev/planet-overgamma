## The Simplest Logger In The World TM.
##
## This is just for nice, readable console output.
## Logger calls also serve as documentation for whatever the code is doing.

import std/strutils
import std/terminal

proc hint*(text: varargs[string, `$`]) =
  stderr.styledWriteLine(styleBright, fgGreen, "h  ",
                         resetStyle, text.join)

proc info*(text: varargs[string, `$`]) =
  stderr.styledWriteLine(styleBright, fgCyan, "i  ",
                         resetStyle, text.join)

proc warning*(text: varargs[string, `$`]) =
  stderr.styledWriteLine(styleBright, fgYellow, "!  ",
                         resetStyle, text.join)

proc error*(text: varargs[string, `$`]) =
  stderr.styledWriteLine(styleBright, fgRed, "!! ",
                         resetStyle, text.join)
