-- The stone furnace is the most basic furnace with fairly inefficient heat
-- transfer capabilities.
-- It is only capable of burning basic low-tier fossil fuels.

local Machine = require "world.machine"

---

local StoneFurnace = Machine:inherit()
StoneFurnace.__name = "stoneFurnace"

return StoneFurnace
