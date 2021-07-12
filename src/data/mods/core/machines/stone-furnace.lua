--- The stone furnace is the most basic furnace with fairly inefficient heat
--- transfer capabilities.
--- It is only capable of burning basic low-tier fossil fuels.

local Machine = require "world.machine"

---

--- @class StoneFurnace: Machine
local StoneFurnace = Machine:inherit()
StoneFurnace.__name = "stoneFurnace"

function StoneFurnace:setup()
  self:addPort("fuel", "in", "item")
end

return StoneFurnace
