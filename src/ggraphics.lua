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
--- @param sx number | nil  X scaling factor
--- @param sy number | nil  Y scaling factor
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
--- @param sx number | nil  X scaling factor
--- @param sy number | nil  Y scaling factor
function ggraphics.drawCenteredQuad(texture, quad, x, y, w, h, sx, sy)
  local _, _, qw, qh = quad:getViewport()
  graphics.draw(texture, quad, x + w / 2, y + w / 2, 0, sx, sy, qw / 2, qh / 2)
end

--- Draws a stippled (dashed) rectangle.
---
--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @param l number  The length of the dashes.
function ggraphics.stippledRectangle(x, y, w, h, l)
  for xx = 0, w / 2, l * 2 do
    local y1, y2 = y, y + h
    graphics.line(x + xx, y1, x + xx + l, y1)
    graphics.line(x + w - xx, y1, x + w - xx - l, y1)
    graphics.line(x + xx, y2, x + xx + l, y2)
    graphics.line(x + w - xx, y2, x + w - xx - l, y2)
  end
  for yy = 0, h / 2, l * 2 do
    local x1, x2 = x, x + h
    graphics.line(x1, y + yy, x1, y + yy + l)
    graphics.line(x1, y + h - yy, x1, y + h - yy - l)
    graphics.line(x2, y + yy, x2, y + yy + l)
    graphics.line(x2, y + h - yy, x2, y + h - yy - l)
  end
end

return ggraphics
