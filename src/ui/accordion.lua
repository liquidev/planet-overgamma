-- Expandable accordions.

local graphics = love.graphics

local rgba = love.math.colorFromBytes

local common = require "common"
local game = require "game"
local style = require "ui.style"
local Ui = require "ui.base"

local fonts = game.fonts
local icons = game.icons

local white = common.white

---

--- Initializes data for the accordion.
local function initData(data, options)
  data.expanded = common.default(options.expandedByDefault, false)
end

--- Returns the icon for the given accordion data.
--- @param data table
--- @return Texture
local function getIcon(data)
  if data.expanded then
    return icons.treeExpanded
  else
    return icons.treeShrinked
  end
end

--- Gets the accordion data for the given title and options.
--- @param ui Ui
--- @param title string
--- @param options table
--- @return table
local function getData(ui, title, options)
  local id = options.id or title
  local data = ui:data("accordion"):get(id, initData, options)
  if data.expanded == nil then
    data.expanded = common.default(options.expandedByDefault, false)
  end
  return data
end

--- Renders the body of an accordion.
--- This returns whether the accordion is expanded.
--- Usage is as follows:
---
--- ```
--- if ui:beginAccordion("Example") then
---  -- draw stuff inside the accordion
--- end
--- ```
---
--- options is a table with the following keys:
---  · id: any
---     The ID is used for storing state between frames.
---     IDs must not clash. If they do clash, a different ID must be provided
---     for state to remain separated. By default, the title is used as the ID.
---  · expandedByDefault: bool = false
---     Controls whether the accordion should be expanded by default.
---
--- @param ui Ui
--- @param title string
--- @param options table
--- @return boolean
function Ui:accordion(title, options)
  -- option handling
  options = options or {}
  local data = getData(self, title, options)

  -- rendering
  local icon = getIcon(data)
  self:push("horizontal", self:width(), icon:getHeight()) do
    -- icon and text
    graphics.setColor(style.accordionIcon)
    self:gicon(icon)
    self:space(6)
    graphics.setColor(style.accordionTitle)
    self:gtext(self:remWidth(), self:height(), fonts.bold, title)
    -- underline
    if self:hover() then
      if self:pressed() then
        graphics.setColor(style.accordionPressed)
      else
        graphics.setColor(style.accordionHover)
      end
      self:lineBottom(1.15)
    end
    -- click event
    if self:clicked() then
      data.expanded = not data.expanded
    end
  end self:pop()

  graphics.setColor(white)

  return data.expanded
end

--- Begins drawing a panel with an expandable accordion and returns whether the
--- accordion is expanded.
--- width, and height are passed to ui:beginPanel(). The panel's layout is
--- always vertical as accordions are meant for expandable vertical containers.
--- title and options are passed to ui:accordion().
--- A matching ui:endPanel() must be called after this, even if this function
--- returns false.
---
--- @param ui Ui
--- @param width number
--- @param height number
--- @param title string
--- @param options table
function Ui:beginAccordionPanel(width, height, title, options)
  options = options or {}
  local expanded = getData(self, title, options).expanded
  if not expanded then
    -- bad magic constant. this is the extra padding the panel adds
    height = 8 * 2 + icons.treeShrinked:getHeight()
  end
  self:beginPanel("vertical", width, height)
  self:accordion(title, options)
  self:space(8)
  return expanded
end

