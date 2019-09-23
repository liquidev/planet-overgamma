#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import strutils

proc fuzzify(str: string): string =
  result = str.toLower().replace(" ", "")

proc `==*`*(a, b: string): bool =
  ## Fuzzy comparison of two strings.
  result = b.fuzzify in a.fuzzify
