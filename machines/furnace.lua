local Furnace = Machine:extend('machine.furnace', 'Furnace')
Furnace.__index = Furnace

Furnace.sprframe = 1
Furnace.categories = { '-item', '+heat' }

function Furnace:update(dt)
    Machine.update(self, dt)

    if self.heat > 0 then self.sprframe = 2
    else self.sprframe = 1 end
end

function Furnace:tick(dt)
    Machine.tick(self, dt)

    self.heat = self.heat - self.heat / 75 * dt

    self:hout(self.heat / 48)
end

function Furnace:iaccept(inv)
    if self.heat <= 800 and inv:consume({ id = 2, amt = 1 }) then
        self.heat = self.heat + 200
    end
end

return Furnace
