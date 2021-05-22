-- Gamma graphics - extra graphics-related utilities.

local graphics = love.graphics

---

local ggraphics = {}

local gradientMesh = love.graphics.newMesh(4, "strip", "stream")

-- Draws a gradient rectangle.
--
-- direction: "horizontal" | "vertical"
-- x, y, w, h: number - the rectangle the gradient should fill
-- color1, color2: color - the colors the gradient should have.
--   order is left→right or top→bottom depending on the direction
function ggraphics.gradientRectangle(direction, x, y, w, h, color1, color2)
  if direction == "horizontal" then
    gradientMesh:setVertex(1, x,     y,     0, 0, unpack(color1))
    gradientMesh:setVertex(2, x + w, y,     0, 0, unpack(color2))
    gradientMesh:setVertex(3, x,     y + h, 0, 0, unpack(color1))
    gradientMesh:setVertex(4, x + w, y + h, 0, 0, unpack(color2))
  elseif direction == "vertical" then
    gradientMesh:setVertex(1, x,     y,     0, 0, unpack(color1))
    gradientMesh:setVertex(2, x + w, y,     0, 0, unpack(color1))
    gradientMesh:setVertex(3, x,     y + h, 0, 0, unpack(color2))
    gradientMesh:setVertex(4, x + w, y + h, 0, 0, unpack(color2))
  else
    error('direction must be "horizontal" or "vertical"')
  end
  graphics.draw(gradientMesh)
end

return ggraphics
