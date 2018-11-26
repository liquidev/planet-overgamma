local Furnace = Machine:extend('machine.furnace', 'Furnace')
Furnace.__index = Furnace

Furnace.sprframe = 1
Furnace.categories = { 'p-heat' }

function Furnace:init()
    Machine.init(self)

    self.heat = 0

    self.bars = {
        heat = { color = {Color.rgb(223, 113, 38)}, progress = 0.0 }
    }
end

function Furnace:update(dt)
    Machine.update(self, dt)

    if self.heat > 0 then self.sprframe = 2 end
end

function Furnace:tick(dt)
    Machine.tick(self, dt)

    self.heat = self.heat - self.heat / 75 * dt
    self.heat = math.clamp(self.heat, 0, 1000)

    self:eachAdjacent('c-heat', function (m)
        local frag = self.heat / 48
        if self.heat > frag and m.heat + frag < 1000 then
            self.heat = self.heat - frag
            m.heat = m.heat + frag
        end
    end)

    self.bars.heat.progress = self.heat / 1000
end

function Furnace:interact()
    if self.heat <= 800 and self.map.player:invconsume({ id = 2, amt = 1 }) then
        self.heat = self.heat + 200
    end
end

return Furnace
