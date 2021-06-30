-- Gamma graphics - extra graphics-related utilities.

local graphics = love.graphics

---

local ggraphics = {}

--- Draws an image centered in a box.
---
--- @param image Image
--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @param sx number X scaling factor
--- @param sx number Y scaling factor
function ggraphics.drawCentered(image, x, y, w, h, sx, sy)
  local iw, ih = image:getDimensions()
  graphics.draw(image, x + w / 2, y + w / 2, 0, sx, sy, iw / 2, ih / 2)
end

--- Draws an quad centered in a box.
---
--- @param image Image
--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @param sx number X scaling factor
--- @param sy number|any Y scaling factor
function ggraphics.drawCenteredQuad(texture, quad, x, y, w, h, sx, sy)
  local _, _, qw, qh = quad:getViewport()
  graphics.draw(texture, quad, x + w / 2, y + w / 2, 0, sx, sy, qw / 2, qh / 2)
end

return ggraphics
