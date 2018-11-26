Machine = Entity:extend('machine', 'Machine')
Machine.__index = Machine

Machine.sprite = 'machines'
Machine.categories = {}

Machine.hassettings = false

function Machine:init()
    self.adjacent = {}
    self.bars = {}
end

function Machine:draw()
    Entity.draw(self)

    jam.gfx.drawhud(function ()
        local box = Hitbox:new(
            self.pos.x - self.hitboxsize[1] / 2,
            self.pos.y - self.hitboxsize[2] / 2,
            self.hitboxsize[1], self.hitboxsize[2])
        if box:has(jam.mapmouse) then
            local h = table.len(self.bars) * 2 + 1
            local y = 0
            for _, b in pairs(self.bars) do
                local dy = self.pos.y - 5 - h + y
                love.graphics.setColor(Color.rgb(0, 0, 0))
                love.graphics.rectangle('fill',
                    self.pos.x - 5 - self.map.scroll.x, dy - self.map.scroll.y, 10, 3)
                love.graphics.setColor(Color.derive(b.color, 0.35))
                love.graphics.rectangle('fill',
                    self.pos.x - 4 - self.map.scroll.x, dy + 1 - self.map.scroll.y, 8, 1)
                love.graphics.setColor(unpack(b.color))
                love.graphics.rectangle('fill',
                    self.pos.x - 4 - self.map.scroll.x, dy + 1 - self.map.scroll.y, math.ceil(8 * b.progress), 1)
                y = y + 2
            end
            love.graphics.setColor(Color.rgb(255, 255, 255))
        end
    end)
end

function Machine:update(dt)
    if self.hassettings then
        local box = Hitbox:new(
            self.pos.x - self.hitboxsize[1] / 2,
            self.pos.y - self.hitboxsize[2] / 2,
            self.hitboxsize[1], self.hitboxsize[2])
        if box:has(jam.mapmouse) then
            self.map.player.laser.scrolloff = dt + 0.1
        end
    end
end

function Machine:tick(dt)
    local mx, my = math.floor((self.pos.x - 4) / 8) + 1, math.floor((self.pos.y - 4) / 8) + 1
    local backblock = self.map:get(1, mx, my)
    if backblock.id == 1 then
        for _, i in pairs(self.block.ingredients) do
            for n = 1, i.amt do
                self.map:spawn(Item:new({
                    id = i.id
                }, self.pos.x, self.pos.y, self.map))
            end
        end
        self.remove = true
    end
    table.clear(self.adjacent)
    self.map:eachEntity(function (ent)
        if ent ~= self then
            if math.dist(self.pos, ent.pos) <= 8 then
                table.insert(self.adjacent, ent)
            end
        end
    end)
end

function Machine:is(category)
    return table.has(self.categories, category)
end

function Machine:eachAdjacent(...)
    local args = {...}
    for _, m in pairs(self.adjacent) do
        local isofcats = true
        for n = 1, #args - 1 do
            if not m:is(args[n]) then isofcats = false; break end
        end
        if isofcats then
            args[#args](m)
        end
    end
end

function Machine:edit(value) end

function Machine:interact() end

function Machine:mousepressed()
    if math.dist(self.map.player.pos, self.pos) < 24 then
        local box = Hitbox:new(
            self.pos.x - self.hitboxsize[1] / 2,
            self.pos.y - self.hitboxsize[2] / 2,
            self.hitboxsize[1], self.hitboxsize[2])
        if box:has(jam.mapmouse) then
            if love.mouse.isDown(2) then self:interact() end
        end
    end
end

function Machine:wheelmoved(_, y)
    if self.hassettings then
        local box = Hitbox:new(
            self.pos.x - self.hitboxsize[1] / 2,
            self.pos.y - self.hitboxsize[2] / 2,
            self.hitboxsize[1], self.hitboxsize[2])
        if box:has(jam.mapmouse) then self:edit(y) end
    end
end
