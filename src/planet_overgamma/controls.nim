## Global controls table.

import std/json

import aglet/input

type
  Controls* = ref object
    kLeft*, kRight*: Key
    kJump*: Key

proc loadControls*(file: string): Controls =
  json.parseFile(file).to(Controls)
