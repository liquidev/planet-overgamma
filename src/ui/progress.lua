-- A fairly simple progress bar.

local graphics = love.graphics

local common = require "common"
local style = require "ui.style"
local Ui = require "ui.base"

local clamp = common.clamp
local white = common.white

---

--- Maps the given value to a green/yellow/red progress bar color.
--- This can be used in conjunction with the color option in Ui:progress to
--- color the progress bar differently depending on the value.
---
--- @param value number            The value to map to a color.
--- @param yellowThreshold number  The minimum value for the color to be yellow.
--- @param redThreshold number     The minimum value for the color to be red.
--- @return Color
function Ui.mapProgressColor(value, yellowThreshold, redThreshold)
  if value >= redThreshold then return style.progressRed
  elseif value >= yellowThreshold then return style.progressYellow
  else return style.progressGreen end
end

local heightThin = 4
local heightTall = 16
local heightWithLabel = 24

-- Returns the group height for the progress bar.
local function getHeight(options)
  if options.label ~= nil then return heightWithLabel
  elseif options.style == "thin" then return heightThin
  else return heightTall end
end

-- Draws the bar part of the progress bar.
local function drawBar(x, y, w, h, value, color)
  graphics.setColor(style.progressBackground)
  graphics.rectangle("fill", x, y, w, h)
  local pw = w * value
  graphics.setColor(color)
  graphics.rectangle("fill", x, y, pw, h)
  graphics.setColor(white)
end

-- Returns the color of text for a given background color.
local function getTextColor(color)
  if common.luma(unpack(color)) > 0.5 then return style.progressDarkText
  else return style.progressLightText end
end

local barRenderers = {

  thin = function (ui, value, color, label)
    local w, h = ui:size()
    drawBar(0, h - heightThin, w, heightThin, value, color)
    if label ~= nil then
      local th = graphics.getFont():getHeight()
      graphics.printf(label, 0, (h - heightThin) / 2 - th / 2, w, "center")
    end
  end,

  tall = function (ui, value, color, label)
    local w, h = ui:size()
    drawBar(0, 0, w, h, value, color)
    if label ~= nil then
      local backgroundColor = getTextColor(style.progressBackground)
      local foregroundColor = getTextColor(color)
      local pw = w * value
      local th = graphics.getFont():getHeight()
      graphics.setStencilTest("greater", 0)

      -- I don't like the fact that LÖVE doesn't let you pass arguments to the
      -- stencil function. Makes this a whole lot less efficient than
      -- it could be :(
      graphics.stencil(function ()
        graphics.rectangle("fill", 0, 0, pw, h)
      end, "replace", 255)
      graphics.setColor(foregroundColor)
      graphics.printf(label, 0, h / 2 - th / 2, w, "center")

      graphics.stencil(function ()
        graphics.rectangle("fill", 0, 0, w, h)
      end, "invert", 0, true)
      graphics.setColor(backgroundColor)
      graphics.printf(label, 0, h / 2 - th / 2, w, "center")

      graphics.setColor(white)
      graphics.setStencilTest()
    end
  end,

}

--- Draws a progress bar in a new group.
--- The options table contains settings for how the progress bar should be
--- rendered.
---
--- options can contain the following values:
---  · width: number - the width of the bar. Defaults to Ui:remWidth().
---  · style: "thin" | "tall" - the style of the progress bar.
---    The thin progress bar normally takes up less space than the tall bar.
---    Adding a label increases the height of both bars, but the bars still look
---    similar to their counterparts without a label.
---    Defaults to "tall".
---  · color: Color - the fill color of the progress bar. Defaults to
---    style.progressGreen.
---  · label: string - the label to render on top of the bar.
---
--- @param value number   A number between 0..1 denoting the progress.
--- @param options table
function Ui:progress(value, options)
  options = options or {}
  -- We don't want a Minecraft Launcher downloading 20/18MB situation here.
  value = clamp(value, 0, 1)

  local width = options.width or self:remWidth()
  local height = getHeight(options)
  self:push("freeform", width, height) do
    self:draw(
      barRenderers[options.style or "tall"],
      self,
      value,
      options.color or style.progressGreen,
      options.label
    )
  end self:pop()
end

