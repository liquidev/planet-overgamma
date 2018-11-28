local ThermalGen = Machine:extend('machine.thermalgenerator', 'Thermal Generator')
ThermalGen.__index = ThermalGen

ThermalGen.sprframe = 7
ThermalGen.categories = { '-heat', '+power' }

function ThermalGen:init()
    Machine.init(self)

    self.heat = 0
    self.power = 0

    self.bars = {
        heat = { color = {Color.rgb(223, 113, 38)}, progress = 0.0 },
        power = { color = {Color.rgb(251, 242, 54)}, progress = 0.0 }
    }
end

function ThermalGen:tick(dt)
    Machine.tick(self, dt)

    local gen = self.heat / 25

    if self.power + gen < 2500 then
        self.power = self.power + gen
        self.heat = self.heat - gen / 2
    end

    self.heat = self.heat - self.heat / 50 * dt
    self.heat = math.clamp(self.heat, 0, 1000)

    self.bars.heat.progress = self.heat / 1000
    self.bars.power.progress = self.power / 2500
end

return ThermalGen
