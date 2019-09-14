#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import json
import tables

import ../debug

type
  Recipe* = ref object
    tier*: int ## Required Assembler tier
    assemblyTime*: float
    ingredients*: Table[string, float]
  RecipeDatabase* = object
    blocks*: OrderedTable[string, Recipe]

proc loadRecipeDatabase*(file: string): RecipeDatabase =
  info("Loading", "recipe database from ", file)
  let obj = json.parseFile(file)
  result = obj.to(RecipeDatabase)
  verbose("RecipeDb", "finished")
