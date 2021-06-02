-- Non-clickthrough panels.

local graphics = love.graphics

local common = require "common"
local style = require "ui.style"

local white = common.white

---

local panel = {}

-- Resets panel-related variables.
function panel._reset(ui)
  ui.mouseOverPanel = false
end

-- Begins drawing a panel.
function panel.beginPanel(ui, layout, width, height)
  ui:push(layout, width, height)

  graphics.setColor(style.panelFill)
  ui:fill()
  graphics.setColor(style.panelOutline)
  ui:outline()
  graphics.setColor(white)

  if ui:hasMouse() then
    ui.mouseOverPanel = true
  end
end

function panel.endPanel(ui)
  ui:pop()
end

return panel
