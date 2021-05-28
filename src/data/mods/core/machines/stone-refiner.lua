-- The stone refiner is a basic refiner powered by heat, that's capable of
-- refining ores at a faster rate than the portAssembler.
-- It doesn't offer any extra yield per raw material.

local Machine = require "world.machine"

---

local StoneRefiner = Machine:inherit()
StoneRefiner.__name = "stoneRefiner"

return StoneRefiner
