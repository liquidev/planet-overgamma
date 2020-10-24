## Common stuff.

import glm/vec

type
  Vertex* {.packed.} = object
    position*: Vec2f
    uv*: Vec2f
    color*: Vec4f
