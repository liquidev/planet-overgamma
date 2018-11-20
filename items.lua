Item = Entity:extend('item', 'Item')
Item.__index = Item

Item.sprite = 'items'

Item.types = {
    [0] = {
        {{range(2, 17)}, amount = {1, 2}},
        {{18}, amount = {1, 1}}
    },
    [1] = {
        {{range(19, 35)}, amount = {1, 3}}
    }
}

Item.gravity = Vector:new(0, 2)
Item.decel = 0.95

function Item:init()
    self.sprframe = self.id

    local angle = math.pi / 2 + love.math.random() * math.pi

    self.vel:set(math.sin(angle), math.cos(angle))
end

function Item:update(dt)
    self:physics(dt)

    self:force(self.gravity:copy():mul(dt))
    self.vel:mul(self.decel)
end

return Item
