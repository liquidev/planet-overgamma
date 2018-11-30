local PowerCell = Machine:extend('machine.powercell', 'Power Cell')
PowerCell.__index = PowerCell

PowerCell.sprframe = 11
PowerCell.categories = { '-power', '+power' }

PowerCell.powercapacity = 10000

function PowerCell:update(dt)
    Machine.update(self, dt)

    self.sprframe = 11
    if self.power > 100 then self.sprframe = 12 end
    if self.power > 2500 then self.sprframe = 13 end
    if self.power > 5000 then self.sprframe = 14 end
    if self.power > 7500 then self.sprframe = 15 end
end

function PowerCell:tick(dt)
    Machine.tick(self, dt)
    self:pout(200)
end

return PowerCell
