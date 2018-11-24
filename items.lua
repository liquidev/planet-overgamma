Item = Entity:extend('item', 'Item')
Item.__index = Item

Item.sprite = 'items'
Item.maxspeed = {}

Item.types = {
    -- basic blocks
    [0] = {
        {{range(2, 17)}, amount = {1, 2}},
        {{18}, amount = {1, 1}}
    },
    [1] = {
        {{range(19, 35)}, amount = {1, 3}}
    },

    -- ores
    [2] = {{{65}, amount = {1, 4}}},
    [3] = {{{66}, amount = {1, 3}}},
    [4] = {{{67}, amount = {1, 3}}},
    [5] = {{{68}, amount = {1, 3}}},
    [6] = {{{69}, amount = {1, 2}}},
    [7] = {{{70}, amount = {1, 2}}},
    [8] = {{{71}, amount = {0, 2}}}
}

Item.gravity = Vector:new(0, 3)
Item.decel = 0.95

function Item:init()
    self.hitboxsize = { 4, 4 }
    self.sprframe = self.id

    local angle = math.pi / 2 + love.math.random() * math.pi

    self.vel:set(math.sin(angle), math.cos(angle))
end

function Item:update(dt)
    self:physics(dt)

    self:force(self.gravity:copy():mul(dt))
    self.vel:mul(self.decel)

    self.pos:limit(4, self.map.width * 8 - 4, -200, (self.map.height + 2) * 8)
    if self.pos.y > self.map.height * 8 then
        self.remove = true
    end
end

return Item
