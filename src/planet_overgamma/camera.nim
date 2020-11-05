## Camera and related transformations.

import aglet
import glm/mat
import glm/vec
import rapid/graphics

type
  Camera* = object
    screenSize*: Vec2f
    position*: Vec2f  ## the position looks at the center of the screen
    scale*: float32

{.push inline.}

proc translation*(camera: Camera): Vec2f =
  ## Returns the translation vector for this camera.
  camera.position * camera.scale - camera.screenSize / 2

proc viewport*(camera: Camera): Rectf =
  ## Returns the viewport rectangle of the camera.
  rectf(camera.translation, camera.screenSize)

proc matrix*(camera: Camera): Mat4f =
  ## Returns a transform matrix for the given camera.
  mat4f()
    .translate(vec3f(-camera.translation, 0))
    .scale(camera.scale)

template transform*(graphics: Graphics, camera: Camera, body: untyped) =
  ## Version of ``graphics.transform`` that additionally takes a camera.
  graphics.transform:
    graphics.translate(-camera.translation)
    graphics.scale(camera.scale)
    `body`

proc toWorld*(camera: Camera, point: Vec2f): Vec2f =
  ## Converts a point from screen coordinates to world coordinates.
  (point + camera.translation) / camera.scale

{.pop.}
