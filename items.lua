Item = Entity:extend('item', 'Item')
Item.__index = Item

Item.sprite = 'items'
Item.maxspeed = {}

Item.types = {
    -- basic blocks
    [0] = { -- fibers
        {{range(2, 17)}, amount = {1, 2}},
        {{18}, amount = {1, 1}}
    },
    [1] = { -- stone
        {{range(19, 35)}, amount = {1, 3}}
    },

    -- ores
    [2] = {{{65}, amount = {1, 4}}}, -- coal
    [3] = {{{66}, amount = {1, 3}}}, -- tin
    [4] = {{{67}, amount = {1, 3}}}, -- copper
    [5] = {{{68}, amount = {1, 3}}}, -- iron
    [6] = {{{69}, amount = {1, 2}}}, -- silver
    [7] = {{{70}, amount = {1, 2}}}, -- gold
    [8] = {{{71}, amount = {0, 2}}}, -- greenium
    [9] = {{{72}, amount = {1, 3}}}, -- nickel

    -- alloys
    [10] = {}, -- invar
    [11] = {}, -- constantan
    [12] = {}, -- bronze
    [13] = {}, -- electrum
}

Item.gravity = Vector:new(0, 3)
Item.decel = 0.95

function Item:init()
    self.hitboxsize = { 4, 4 }
    self.sprframe = self.id

    self.amount = self.amount or 1

    local angle = math.pi / 2 + love.math.random() * math.pi

    self.vel:set(math.sin(angle), math.cos(angle))
end

function Item:draw()
    if self.amount >= 2 then
        self:drawSprite(self.pos.x + 2, self.pos.y - 2)
    end

    Entity.draw(self)
end

function Item:update(dt)
    self:physics(dt)

    self:force(self.gravity:copy():mul(dt))
    self.vel:mul(self.decel)

    self.pos:limit(4, self.map.width * 8 - 4, -200, (self.map.height + 2) * 8)
    if self.pos.y > self.map.height * 8 then
        self.remove = true
    end

    if self.amount <= 0 then self.remove = true end
end

return Item
