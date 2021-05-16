-- Simple immediate-mode UI library.

local Object = require "object"
local Rect = require "rect"
local Vec = require "vec"

---

local Ui = Object:inherit()

-- Initializes a new UI instance.
function Ui:init()
end

-- Clears the stack and pushes a new initial box onto it, with the provided
-- width, height, and layout.
function Ui:begin(width, height, layout)
  self.stack = {
    {
      rect = Rect:new(0, 0, width, height),
      cursor = Vec(0, 0),
      layout = layout,
    }
  }
end

-- Returns the topmost box on the stack.
function Ui:top()
  return self.stack[#self.stack]
end

-- Pushes a new box onto the stack.
function Ui:push(width, height, layout)
  local top = self:top()
  table.insert(self.stack, {
    rect = Rect:new(top.rect.x, top.rect.y, width, height),
    cursor = Vec(0, 0),
    layout = layout,
  })
end

-- Pops the topmost box off the stack.
function Ui:pop()
  self.stack[#self.stack] = nil
end

return Ui

