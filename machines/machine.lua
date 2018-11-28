Machine = Entity:extend('machine', 'Machine')
Machine.__index = Machine

Machine.sprite = 'machines'
Machine.categories = {}

Machine.hassettings = false

function Machine:init()
    self.adjacent = {}
    self.bars = {}

    self.connecting = false
    self.connections = {}

    if table.has(self.categories, '*inv') then
        self.inventory = Inventory:new(unpack(deepcopy(self.invsettings)))
    end
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
            love.graphics.setColor(Color.rgb(95, 205, 228))
            for _, c in pairs(self.connections) do
                love.graphics.line(
                    self.pos.x - self.map.scroll.x,
                    self.pos.y - self.map.scroll.y,
                    c.machine.pos.x - c.machine.map.scroll.x,
                    c.machine.pos.y - c.machine.map.scroll.y)
            end
            love.graphics.setColor(Color.rgb(255, 255, 255))
        end
        if self.connecting then
            love.graphics.setColor(Color.rgb(95, 205, 228))
            love.graphics.line(self.pos.x - self.map.scroll.x, self.pos.y - self.map.scroll.y, jam.mouse.x, jam.mouse.y)
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
        if table.has(self.categories, '*inv') then
            for t, i in pairs(self.inventory.items) do
                if i.amount > 0 then
                    self.map:spawn(Item:new({
                        id = t,
                        amount = i.amount
                    }, self.pos.x, self.pos.y, self.map))
                end
            end
        end
        self.remove = true
    end
    table.clear(self.adjacent)
    self.map:eachEntity(function (ent)
        if ent ~= self then
            if ent:oftype('machine') and math.dist(self.pos, ent.pos) <= 8 then
                table.insert(self.adjacent, ent)
            end
        end
    end)
    for i, c in pairs(self.connections) do
        if c.machine.remove then
            table.remove(self.connections, i)
        end
    end
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

function Machine:eachConnected(f)
    for _, c in pairs(self.connections) do
        f(c.machine)
    end
end

function Machine:iaccept(inventory)
    if table.has(self.categories, '-item') or table.has(self.categories, '*inv') then
        self:onitems(inventory)
    end
end

function Machine:onitems(inventory) end

function Machine:edit(value) end

function Machine:interact() end

function Machine:mousepressed()
    if love.mouse.isDown(3) and self.connecting then
        self.map:eachEntity(function (m)
            if m ~= self and math.dist(m.map.player.pos, m.pos) then
                if m:oftype('machine') then
                    local mbox = Hitbox:new(
                        m.pos.x - m.hitboxsize[1] / 2,
                        m.pos.y - m.hitboxsize[2] / 2,
                        m.hitboxsize[1], m.hitboxsize[2])
                    if mbox:has(jam.mapmouse) then
                        if math.dist(self.pos, m.pos) <= 8 then
                            table.insert(self.connections, {
                                type = 'out',
                                machine = m
                            })
                            self.connecting = false
                            return
                        end
                    end
                end
            end
            self.connecting = false
        end)
    end

    if math.dist(self.map.player.pos, self.pos) < 24 then
        local box = Hitbox:new(
            self.pos.x - self.hitboxsize[1] / 2,
            self.pos.y - self.hitboxsize[2] / 2,
            self.hitboxsize[1], self.hitboxsize[2])
        if box:has(jam.mapmouse) then
            if love.mouse.isDown(2) then
                self:interact()
                self:iaccept(self.map.player.inventory)
            end
            if self:is('*out') and love.mouse.isDown(3) then
                if not self.connecting and #self.connections == 0 then
                    self.connecting = true
                    return
                end
                if love.mouse.isDown(3) and #self.connections > 0 then
                    table.clear(self.connections)
                end
            end
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
