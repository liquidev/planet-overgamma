#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import os
import parseopt
import tables

import ../../debug
import ../../res

proc loadCmdline*() =
  info("Parsing", "command line arguments")
  var opt = initOptParser(commandLineParams())
  for kind, k, v in getopt(opt):
    args[k] = v