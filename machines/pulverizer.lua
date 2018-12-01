local Pulverizer = Machine:extend('machine.pulverizer', 'Pulverizer')
Pulverizer.__index = Pulverizer

Pulverizer.sprframe = 17
Pulverizer.categories = { '*out', '-item', '+item', '-power' }
Pulverizer.hassettings = true

Pulverizer.recipes = {
    {
        power = 200,
        ingredients = { {id = 1, amt = 1} },
        product = { id = 15, amt = {1, 2} }
    },
    {
        power = 400,
        ingredients = { {id = 15, amt = 1} },
        product = { id = 14, amt = {0, 3} }
    }
}

function Pulverizer:init()
    Machine.init(self)

    self.item = 0
end

function Pulverizer:update(dt)
    Machine.update(self, dt)

    self.sprframe = 17 + self.item
end

function Pulverizer:edit(value)
    self.item = (self.item + value) % #Pulverizer.recipes
end

function Pulverizer:onitems(inv)
    for i, r in pairs(Pulverizer.recipes) do
        if i == self.item + 1 then
            if self.power >= r.power and (inv:consume(unpack(r.ingredients))) then
                local n = love.math.random(r.product.amt[1], r.product.amt[2])
                self:iout(r.product.id, n)
                self.power = self.power - r.power
            end
        end
    end
end

return Pulverizer
