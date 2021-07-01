-- A function for making groups scrollable.

local graphics = love.graphics

local common = require "common"
local style = require "ui.style"
local tween = require "tween"
local Ui = require "ui.base"

local white = common.white

---

--
-- Configuration
--

Ui.scrollIncrement = 48

local scrollbarWidth = 2

local function initData(data)
  data.scroll = 0
end

--
-- Rendering
--

local function drawInner(scroll, direction, func, ...)
  graphics.push()
  if direction == "horizontal" then
    graphics.translate(-math.floor(scroll), 0)
  else
    graphics.translate(0, -math.floor(scroll))
  end
  func(...)
  graphics.pop()
end

--- Renders and processes events for a scrollable group.
---
--- id must be a unique ID to identify the group by.
--- func is called with the vararg parameters when it is time to render the
--- inside of the scrollable group.
---
--- @param id any
--- @param direction '"horizontal"' | '"vertical"'
--- @param func function
--- @vararg  Passed to `func`.
function Ui:scroll(id, direction, height, func, ...)
  -- This function's API is not a push-pop based one because of how Ui:clip()
  -- works.

  assert(direction == "horizontal" or direction == "vertical",
         "the scroll direction must be 'horizontal' or 'vertical'")

  local data = self:data("scroll"):get(id, initData)
  local oldmx, oldmy = self.mouseOffset:xy()
  local deltaScroll = self.input.deltaScroll.y

  -- We don't want to trigger scroll events in any sub-groups.
  self.input.deltaScroll.y = 0
  -- We also want sub-groups to receive hover events in the proper place.
  if direction == "horizontal" then
    self.mouseOffset.x = data.scroll
  else
    -- Let's assume that freeform layouts should also use vertical scrolling.
    self.mouseOffset.y = data.scroll
  end
  -- We also don't want sub-groups to draw outside the scroll area.
  self:clip(drawInner, data.scroll, direction, func, ...)
  self.mouseOffset:set(oldmx, oldmy)
  self.input.deltaScroll.y = deltaScroll

  -- Draw the scroll bar.
  local x, y = self:top().rect:xywh()
  local groupWidth, groupHeight = self:size()
  local maxScroll = math.max(0, height - groupHeight)
  local barRatio = groupHeight / height
  if barRatio < 1 then
    local barHeight = groupHeight * barRatio
    local scrollRatio = data.scroll / maxScroll
    local barY = (groupHeight - barHeight) * scrollRatio
    graphics.setColor(style.scrollBar)
    graphics.rectangle("fill", x + groupWidth - scrollbarWidth, y + barY,
                       scrollbarWidth, barHeight)
    graphics.setColor(white)
  end

  -- Animate scrolling.
  if deltaScroll ~= 0 then
    tween.finish(data.tween)
    local to = data.scroll - deltaScroll * Ui.scrollIncrement
    to = common.clamp(to, 0, maxScroll)
    data.tween = tween.start(to, 0.3, "quinticOut", tween.field(data, "scroll"))
  end
end
