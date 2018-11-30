local HeatingCoil = Machine:extend('machine.heatingcoil', 'Heating Coil')
HeatingCoil.__index = HeatingCoil

HeatingCoil.sprframe = 10
HeatingCoil.categories = { '-power', '+heat' }

function HeatingCoil:tick(dt)
    Machine.tick(self, dt)

    if self.power > 500 then
        if self.heat < 900 then
            self.heat = self.heat + 100
            self.power = self.power - 50
        end
    end

    self.heat = self.heat - self.heat / 50 * dt

    self:hout(self.heat / 48)
end

return HeatingCoil
