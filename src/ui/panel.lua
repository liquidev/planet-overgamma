-- Non-clickthrough panels.

local graphics = love.graphics

local common = require "common"
local style = require "ui.style"
local Ui = require "ui.base"

local white = common.white

---

local begin = Ui.begin
function Ui:begin(...)
  begin(self, ...)
  local data = self:data("panel")
  data.hasMouse = false
end

--- Returns whether the mouse is currently over a panel.
function Ui:mouseOverPanel()
  return self:data("panel").hasMouse
end

--- Begins drawing a panel.
--- @param layout '"freeform"' | '"horizontal"' | '"vertical"'
--- @param width number
--- @param height number
function Ui:beginPanel(layout, width, height)
  self:push("freeform", width, height) -- outer container

  graphics.setColor(style.panelFill)
  self:fill()
  graphics.setColor(style.panelOutline)
  self:outline()
  graphics.setColor(white)

  if self:hover() then
    self:data("panel").hasMouse = true
  end

  self:push(layout, self:size()) -- inner content
  self:pad(8)
end

--- Ends drawing a panel.
function Ui:endPanel()
  self:pop() -- inner content
  self:pop() -- outer container
end

