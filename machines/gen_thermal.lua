local ThermalGen = Machine:extend('machine.thermalgenerator', 'Thermal Generator')
ThermalGen.__index = ThermalGen

ThermalGen.sprframe = 7
ThermalGen.categories = { '-heat', '+power' }

function ThermalGen:tick(dt)
    Machine.tick(self, dt)

    local gen = self.heat / 25

    if self.power + gen < 2500 then
        self.power = self.power + gen
        self.heat = self.heat - gen / 2
    end

    self:pout(100)

    self.heat = self.heat - self.heat / 50 * dt
end

return ThermalGen
