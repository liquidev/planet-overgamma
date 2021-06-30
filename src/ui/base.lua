-- The base interface of the UI. This is expanded with controls in other
-- modules.

local graphics = love.graphics

local Input = require "input"
local Object = require "object"
local Rect = require "rect"
local Vec = require "vec"

---

--- @class Ui: Object
local Ui = Object:inherit()

--- Initializes a new UI instance.
function Ui:init()
  self.input = Input:new()
  self.controlData = {}
end


--
-- Layout
--

--- Clears the stack and pushes a new initial group onto it, with the provided
--- layout, width, and height.
--- The width and height default to `love.graphics.getDimensions()`.
---
--- @param layout '"freeform"' | '"vertical"' | '"horizontal"'
--- @param width number
--- @param height number
function Ui:begin(layout, width, height)
  if width == nil then
    width, height = graphics.getDimensions()
  end
  self.stack = {
    {
      rect = Rect:new(0, 0, width, height),
      cursor = Vec(0, 0),
      layout = layout,
    }
  }
end

--- Returns the topmost group on the stack.
--- If offset is provided and greater than 0, returns the nth group relative to
--- the top of the stack.
---
--- @return table
function Ui:top(offset)
  offset = offset or 0
  return self.stack[#self.stack - offset]
end

--- Returns the size of the current group.
---
--- @return number width
--- @return number height
function Ui:size()
  local rect = self:top().rect
  return rect.width, rect.height
end

--- Returns the width of the current group.
---
--- @return number
function Ui:width()
  return self:top().rect.width
end

--- Returns the height of the current group.
---
--- @return number
function Ui:height()
  return self:top().rect.height
end

--- Returns the "remaining" width in the current layout, that is, the remaining
--- horizontal space in which groups can still fit.
--- The value returned by this is determined by the current group's cursor.
---
--- @return number
function Ui:remWidth()
  local top = self:top()
  return top.rect.width - top.cursor.x
end

--- Returns the "remaining" height in the current layout, that is, the remaining
--- vertical space in which groups can still fit.
--- The value returned by this is determined by the current group's cursor.
---
--- @return number
function Ui:remHeight()
  local top = self:top()
  return top.rect.height - top.cursor.y
end

--- Returns the total remaining size according to the semantics of
--- remWidth and remHeight.
---
--- @return number remWidth
--- @return number remHeight
function Ui:remSize()
  local top = self:top()
  local rect = top.rect
  local cursor = top.cursor
  return rect.width - cursor.x, rect.height - cursor.y
end

--- Pushes a new group onto the stack.
--- layout must be one of:
---  · "freeform" - elements are laid out manually
---  · "horizontal" - elements are laid out left to right
---  · "vertical" - elements are laid out top to bottom
--- The default values for width/height is ui:size().
---
--- @param layout '"freeform"' | '"vertical"' | '"horizontal"'
--- @param width number
--- @param height number
function Ui:push(layout, width, height)
  layout = layout or "freeform"
  width = width or self:width()
  height = height or self:height()

  local top =
    assert(self:top(), "at least one group must be present for Ui:push to work")
  local cursor = top.cursor
  table.insert(self.stack, {
    rect =
      Rect:new(top.rect.x + cursor.x, top.rect.y + cursor.y, width, height),
    cursor = Vec(0, 0),
    layout = layout or "freeform",
  })
end

--- Moves the given cursor Vec by the X or Y amount according to the given
--- layout.
--- @param layout '"freeform"' | '"vertical"' | '"horizontal"'
--- @param cursor Vec
--- @param x number
--- @param y number
local function moveCursor(layout, cursor, x, y)
  if layout == "horizontal" then
    cursor.x = cursor.x + x
  elseif layout == "vertical" then
    cursor.y = cursor.y + y
  end
end

--- Pops the topmost group off the stack.
function Ui:pop()
  local top = self:top()
  local parent = self:top(1)
  moveCursor(parent.layout, parent.cursor, top.rect.width, top.rect.height)
  self.stack[#self.stack] = nil
end

--- Inserts blank space between elements in the current group.
---
--- @param amount number
function Ui:space(amount)
  local top = self:top()
  moveCursor(top.layout, top.cursor, amount, amount)
end

--- Adds padding to the current group's rectangle.
--- If amounts is a number, padding is equal on all sides.
--- If amounts is a table, padding depends on the fields:
---  · horizontal, vertical - applies equal padding to left/right and top/bottom
---  · right, bottom, top, left - applies separate padding amounts to all sides
---
--- @param amounts number | table
function Ui:pad(amounts)
  local right, bottom, top, left
  if type(amounts) == "number" then
    right, bottom, top, left = amounts, amounts, amounts, amounts
  elseif type(amounts) == "table" then
    if amounts.right ~= nil then
      right, bottom, top, left =
        amounts.right, amounts.bottom, amounts.top, amounts.left
    else
      right, bottom, top, left =
        amounts.horizontal, amounts.vertical,
        amounts.horizontal, amounts.vertical
    end
  else
    error("amounts must be a number or a table")
  end
  local rect = self:top().rect
  rect.x = rect.x + left
  rect.y = rect.y + top
  rect.width = rect.width - left - right
  rect.height = rect.height - top - bottom
end

--- Wraps groups around in a horizontal or vertical container.
--- If the cursor's X or Y position lands outside of the container, it's reset
--- to 0, and the opposite axis is incremented by `size`.
--- Errors out if the layout is not horizontal or vertical.
---
--- @param size number  Defines the row height or column width.
function Ui:wrap(size)
  local top = self:top()
  local cursor = top.cursor
  if top.layout == "horizontal" then
    if cursor.x >= top.rect.width then
      cursor.x = 0
      cursor.y = cursor.y + size
    end
  elseif top.layout == "vertical" then
    if cursor.y >= top.rect.height then
      cursor.x = cursor.x + size
      cursor.y = 0
    end
  else
    error("the topmost group's layout must be 'horizontal' or 'vertical'")
  end
end


--
-- Rendering
--

local function rectangleImpl(ui, mode, rx, ry, segments)
  local x, y, w, h = ui:top().rect:xywh()
  if mode == "line" and graphics.getLineWidth() % 2 > 0.5 then
    x, y = x + 0.5, y + 0.5
    w, h = w - 1, h - 1
  end
  graphics.rectangle(mode, x, y, w, h, rx, ry, segments)
end

--- Fills the topmost group with a solid color depending on the one set in
--- `love.graphics.setColor`.
--- rx, ry, segments control the corner roundness and are passed to
--- `love.graphics.rectangle` as-is.
---
--- @param rx number
--- @param ry number
--- @param segments number
function Ui:fill(rx, ry, segments)
  rectangleImpl(self, "fill", rx, ry, segments)
end

--- Outlines the topmost group with a line dependent on parameters set in
--- `love.graphics`.
--- Parameters have the same meaning as in `Ui:fill`.
---
--- @param rx number
--- @param ry number
--- @param segments number
function Ui:outline(rx, ry, segments)
  rectangleImpl(self, "line", rx, ry, segments)
end

--- Draws a line spanning the bottom of the current group.
--- The offset is the multiplier to be applied to the group's height, and can
--- be used to add some spacing between the group's bottom and the line drawn.
--- Defaults to 1.
---
--- @param offset number
function Ui:lineBottom(offset)
  offset = offset or 1
  local rect = self:top().rect
  local y = math.floor(rect.y + rect.height * offset) + 0.5
  graphics.line(rect:left() + 0.5, y, rect:right() + 0.5, y)
end

--- Counts lines in the given string.
---
--- @param text string
local function countLines(text)
  local count = 1
  for _ in text:gmatch("\r?\n") do
    count = count + 1
  end
  return count
end

--- Calculates the height of the given text.
---
--- @param font Font
--- @param text string
local function textHeight(font, text)
  local lineCount = countLines(text)
  local baseHeight = font:getHeight() + 1
  local extraHeight = baseHeight * font:getLineHeight() - baseHeight
  return baseHeight * lineCount + extraHeight * (lineCount - 1)
end

--- Draws text inside the current group, using the current font in love.graphics.
--- This function accepts the following parameters:
---  · text, alignh, alignv: string
---  · font: Font; text, alignh, alignv: string
--- alignh and alignv control the alignment of the text.
--- By default, alignh is "left" and alignv is "middle".
--- These can take the following values:
---  · alignh: "left", "center", "right"
---  · alignv: "top", "middle", "bottom"
function Ui:text(...)
  local font = graphics.getFont()
  local text, alignh, alignv
  if type(select(1, ...)) == "userdata" then
    font, text, alignh, alignv = ...
  else
    text, alignh, alignv = ...
  end
  alignh = alignh or "left"
  alignv = alignv or "middle"

  local x, ry, w, h = self:top().rect:xywh()
  local th = textHeight(font, text)
  local y
  if alignv == "top" then y = ry
  elseif alignv == "middle" then y = ry + h / 2 - th / 2
  elseif alignv == "right" then y = ry + h - th end

  graphics.printf(text, font, x, y, w, alignh)
end

--- Draws text inside of a new group. width and height specify the size of the
--- group, and the rest of parameters is passed to Ui:text.
---
--- @param width number
--- @param height number
function Ui:gtext(width, height, ...)
  self:push("freeform", width, height) do
    self:text(...)
  end self:pop()
end

--- Draws on top of the current group. fn is the function that performs the
--- drawing. Any arguments following the function are passed to it.
---
--- @param fn function
function Ui:draw(fn, ...)
  local x, y = self:top().rect:xywh()
  graphics.translate(x, y)
  fn(...)
  graphics.translate(-x, -y)
end

-- Implementation of gicon.
local function drawIcon(icon, dx, dy)
  graphics.draw(icon, dx, dy)
end

--- Renders an icon in a new group.
--- width and height specify the size of the group. The icon is always rendered
--- at full scale.
--- The color of the icon can be manipulated using `love.graphics.setColor`.
---
--- @param icon Texture
--- @param width number | nil
--- @param height number | nil
function Ui:gicon(icon, width, height)
  local iconWidth, iconHeight = icon:getDimensions()
  width = width or iconWidth
  height = height or iconHeight

  self:push("freeform", width, height)
  local x = width / 2 - iconWidth / 2
  local y = height / 2 - iconHeight / 2
  self:draw(drawIcon, icon, x, y)
  self:pop()
end


--
-- Input
--

--- Returns whether the mouse cursor is in the current group.
--- @return boolean
function Ui:hover()
  return self:top().rect:hasPoint(self.input.mouse)
end

--- Returns whether the cursor is over the current group and the left mouse
--- button is being held down.
--- @return boolean
function Ui:pressed()
  return self:hover() and self.input:mouseDown(Input.mbLeft)
end

--- Returns whether the cursor is over the current group and
--- the left mouse button has just been clicked.
--- @return boolean
function Ui:clicked()
  return self:hover() and self.input:mouseJustReleased(Input.mbLeft)
end


--
-- Control data
--

--- @class ControlData: Object
local ControlData = Object:inherit()

--- Initializes a control data store.
function ControlData:init()
  self.controls = setmetatable({}, { __mode = 'k' })
end

--- Gets data for a control with the given ID.
--- @param id any
--- @return table
function ControlData:get(id)
  if self.controls[id] == nil then
    self.controls[id] = {}
  end
  return self.controls[id]
end

--- Returns control data for the control with the given key.
--- @param key string
--- @return ControlData
function Ui:data(key)
  if self.controlData[key] == nil then
    self.controlData[key] = ControlData:new()
  end
  return self.controlData[key]
end

---

return Ui

