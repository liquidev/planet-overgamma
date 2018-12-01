local SolarPanel = Machine:extend('machine.solar_panel', 'Solar Panel')
SolarPanel.__index = SolarPanel

SolarPanel.sprframe = 16
SolarPanel.categories = { 'solar', '+power' }

function SolarPanel:tick(dt)
    Machine.tick(self, dt)

    local skyaccess = true
    if self.map.mine then skyaccess = false
    else
        local block = self:position()
        for y = block.y - 1, 0, -1 do
            local tile = self.map:get(1, block.x + 1, y + 1)
            if tile.id ~= 1 then
                skyaccess = false
                break
            end
        end
    end

    if skyaccess then
        self.power = self.power + 50 * dt
    end

    self:eachAdjacent('solar', function (m)
        if self.pos.x < m.pos.x then
            local amt = math.min(self.power, 100)
            if m.power + amt < 2500 then
                self.power = self.power - amt
                m.power = m.power + amt
            end
        end
    end)

    self:pout(200)
end

return SolarPanel
