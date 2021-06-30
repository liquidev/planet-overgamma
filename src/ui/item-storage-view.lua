-- The UI component for viewing and manipulating item storages.

local graphics = love.graphics

local common = require "common"
local game = require "game"
local ggraphics = require "ggraphics"
local items = require "items"
local style = require "ui.style"
local Ui = require "ui.base"

local white = common.white

local uqty = items.unitQuantity

---

local cellSize = 36

-- @param ui Ui
-- @param storage ItemStorage
-- @param options table
-- @param stack ItemStack
local function drawStack(ui, storage, options, stack)
  local cs = cellSize
  local quad = game.items[stack.id].quad
  graphics.setColor(style.itemStorageCellOutline)
  graphics.rectangle("line", 0.5, 0.5, cs, cs)
  graphics.setColor(white)
  ggraphics.drawCenteredQuad(game.itemAtlas.image, quad, 0, 0, cs, cs, 3)
  graphics.print(uqty(stack.amount), game.fonts.regular10, 2, cs - 12)
end

local function drawInner(ui, storage, options)
  -- stacks
  for _, stack in ipairs(storage:sorted("amount", "descending")) do
    ui:wrap(cellSize)
    ui:push("freeform", cellSize, cellSize) do
      if ui:hover() then
        graphics.setColor(style.itemStorageCellHover)
        ui:fill()
        graphics.setColor(white)
      end
      ui:draw(drawStack, ui, storage, options, stack)
    end ui:pop()
  end
  -- empty message
  if options.emptyText ~= nil and storage:occupied() == 0 then
    graphics.setColor(style.itemStorageEmptyText)
    ui:text(options.emptyText, "center", "middle")
    graphics.setColor(white)
  end
end

local function getInnerHeight(storage, columns)
  return math.ceil(storage:stackCount() / columns) * cellSize
end

--- Draws and processes events for an item storage view.
---
--- options must have the following values:
---  · columns: number - the number of columns
---  · height: number - the total height of the view
---  · emptyText: string | nil - the text to display when the storage is empty
---
--- @param storage ItemStorage
--- @param options table
function Ui:itemStorageView(storage, options)
  local columns = assert(options.columns, "column count must be provided")
  local height = assert(options.height, "height must be provided")

  self:push("horizontal", columns * cellSize, height) do
    -- the outline
    graphics.setColor(style.itemStorageOutline)
    self:outline()
    graphics.setColor(white)
    -- inner stuff (stacks or the empty storage message)
    local innerHeight = getInnerHeight(storage, columns)
    self:scroll(storage, "vertical", innerHeight,
                drawInner, self, storage, options)
  end self:pop()
end
