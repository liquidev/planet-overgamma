local Smelter = Machine:extend('machine.smelter', 'Furnace')
Smelter.__index = Smelter

Smelter.sprframe = 3
Smelter.hassettings = true
Smelter.categories = { 'c-heat', 'p-item' }

function Smelter:init()
    Machine.init(self)

    self.bars = {
        heat = { color = {Color.rgb(223, 113, 38)}, progress = 0.0 }
    }

    self.heat = 0
    self.alloy = 0
end

function Smelter:tick(dt)
    Machine.tick(self, dt)

    self.sprframe = 3 + self.alloy

    self.heat = self.heat - self.heat / 25 * dt
    self.heat = math.clamp(self.heat, 0, 1000)

    self.bars.heat.progress = self.heat / 1000
end

function Smelter:edit(value)
    self.alloy = (self.alloy + value) % 4
end

function Smelter:interact(value)
    if self.alloy == 0 -- Invar -- 1 iron, 2 nickel; 700 HU
    and self.heat >= 700 and self.map.player:invconsume({ id = 5, amt = 1 }, { id = 9, amt = 2 }) then
        jam.spawn(Item:new({ id = 10 }, self.pos.x, self.pos.y, self.map))
    end
    if self.alloy == 1 -- Constantan -- 1 copper, 1 nickel; 800 HU
    and self.heat >= 800 and self.map.player:invconsume({ id = 4, amt = 1 }, { id = 9, amt = 1 }) then
        jam.spawn(Item:new({ id = 11 }, self.pos.x, self.pos.y, self.map))
    end
    if self.alloy == 2 -- Bronze -- 3 copper, 1 tin; 600 HU
    and self.heat >= 600 and self.map.player:invconsume({ id = 3, amt = 1 }, { id = 4, amt = 3 }) then
        jam.spawn(Item:new({ id = 12 }, self.pos.x, self.pos.y, self.map))
    end
    if self.alloy == 3 -- Electrum -- 1 silver, 1 gold; 400 HU
    and self.heat >= 400 and self.map.player:invconsume({ id = 6, amt = 1 }, { id = 7, amt = 1 }) then
        jam.spawn(Item:new({ id = 13 }, self.pos.x, self.pos.y, self.map))
    end
end

return Smelter
