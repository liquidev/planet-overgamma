## Global controls table.

import aglet/input

type
  Controls* = ref object
    kLeft*, kRight*: Key
    kJump*: Key
