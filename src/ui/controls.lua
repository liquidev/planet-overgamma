-- Patches all controls into the UI object.

local Ui = require "ui"

---

local function patch(t)
  for k, _ in pairs(t) do
    if k:sub(1, 1) ~= '_' then
      Ui[k] = t[k]
    end
  end
end

local panel = require "ui.panel"

patch(panel)

local begin = Ui.begin
function Ui:begin(...)
  begin(self, ...)
  panel._reset(self)
end
