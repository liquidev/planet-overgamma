local Miner = Machine:extend('machine.miner', 'Miner')
Miner.__index = Miner

Miner.sprframe = 20
Miner.categories = { '*out', '+item', '-power' }
Miner.hassettings = true

Miner.ores = {
    [65] = {
        power = 50,
        out = { id = 2, amt = {1, 2} }
    },
    [66] = {
        power = 100,
        out = { id = 3, amt = {1, 2} }
    },
    [67] = {
        power = 100,
        out = { id = 4, amt = {1, 2} }
    },
    [68] = {
        power = 150,
        out = { id = 5, amt = {1, 2} }
    },
    [69] = {
        power = 200,
        out = { id = 6, amt = {1, 1} }
    },
    [70] = {
        power = 200,
        out = { id = 7, amt = {1, 1} }
    },
    [71] = {
        power = 2400,
        out = { id = 8, amt = {0, 1} }
    },
    [72] = {
        power = 150,
        out = { id = 9, amt = {1, 2} }
    },
}

function Miner:init()
    Machine.init(self)

    self.direction = 0
    self.time = 0
end

function Miner:update(dt)
    Machine.update(self, dt)

    self.rotation = self.direction * (math.pi / 2)
end

function Miner:tick(dt)
    Machine.tick(self, dt)

    self.time = self.time + dt

    if self.time > 2 then
        local pusage, id, amt
        if self.direction == 0 then pusage, id, amt = self:mine(1, 0) end
        if self.direction == 1 then pusage, id, amt = self:mine(0, 1) end
        if self.direction == 2 then pusage, id, amt = self:mine(-1, 0) end
        if self.direction == 3 then pusage, id, amt = self:mine(0, -1) end

        if pusage ~= nil then
            if self.power >= pusage then
                self:iout(id, amt)
                self.power = self.power - pusage
                self.time = 0
            end
        end
    end
end

function Miner:mine(x, y)
    local tile = self.map:get(2, self:mappos(x, y))
    local pusage = 0
    for i, o in pairs(Miner.ores) do
        if tile.id == i then
            pusage = pusage + o.power
            local n = love.math.random(o.out.amt[1], o.out.amt[2])
            return pusage, o.out.id, n
        end
    end
end

function Miner:edit(value)
    self.direction = (self.direction + value) % 4
end

return Miner
