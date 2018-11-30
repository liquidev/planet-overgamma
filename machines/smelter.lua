local Smelter = Machine:extend('machine.smelter', 'Furnace')
Smelter.__index = Smelter

Smelter.sprframe = 3
Smelter.categories = { '*out', '-heat', '-item', '+item' }
Smelter.hassettings = true

Smelter.heatcapacity = 1500

Smelter.alloys = {
    {
        heat = 700,
        ingredients = { {id = 5, amt = 1}, {id = 9, amt = 2} },
        alloy = {id = 10, amt = 3}
    },
    {
        heat = 800,
        ingredients = { {id = 4, amt = 1}, {id = 9, amt = 1} },
        alloy = {id = 11, amt = 2}
    },
    {
        heat = 600,
        ingredients = { {id = 3, amt = 1}, {id = 4, amt = 3} },
        alloy = {id = 12, amt = 4}
    },
    {
        heat = 400,
        ingredients = { {id = 6, amt = 1}, {id = 7, amt = 1} },
        alloy = {id = 13, amt = 2}
    }
}

function Smelter:init()
    Machine.init(self)

    self.alloy = 0
end

function Smelter:tick(dt)
    Machine.tick(self, dt)

    self.sprframe = 3 + self.alloy

    self.heat = self.heat - self.heat / 25 * dt
end

function Smelter:edit(value)
    self.alloy = (self.alloy + value) % #Smelter.alloys
end

function Smelter:onitems(inv)
    for i, a in pairs(Smelter.alloys) do
        if i == self.alloy + 1 then
            if self.heat >= a.heat and (inv:consume(unpack(a.ingredients))) then
                self:iout(a.alloy.id, a.alloy.amt)
            end
        end
    end
end

return Smelter
