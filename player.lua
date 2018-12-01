Player = PlatformerPlayer:extend('player', 'Player')
Player.__index = Player

Player.gravity = Vector:new(0, 50)
Player.maxspeed = { 0.7, 2 }

function Player:init()
    PlatformerPlayer.init(self, dt)

    self.map.player = self

    self.laser = {}
    self.laser.mode = 'none'
    self.laser.aim = Vector:new()
    self.laser.power = 0

    -- laser: placement
    self.laser.block = 1
    self.laser.hudtime = 0
    self.laser.scrolloff = 0

    self.screen = Vector:new(math.floor(self.pos.x / 96), math.floor(self.pos.y / 96))
    self.map.scroll:set(self.screen.x * 96, self.pos.y - 96 / 2)

    self.inventory = Inventory:new({
        owner = self,
        onchange = function (item)
            item.disptime = love.timer.getTime() + 2
        end
    }, 65535, { amount = 0, disptime = 0 })
end

function Player:draw()
    PlatformerPlayer.draw(self)

    if self.laser.mode ~= 'none' then
        if self.laser.mode == 'destroy' then love.graphics.setColor(Color.rgb(255, 0, 68)) end
        if self.laser.mode == 'place' then love.graphics.setColor(Color.rgb(44, 232, 245)) end
        love.graphics.setLineWidth(self.laser.power)
        love.graphics.line(self.pos.x, self.pos.y, self.laser.aim.x * 8 + 4, self.laser.aim.y * 8 + 4)
        love.graphics.circle('fill', self.laser.aim.x * 8 + 4, self.laser.aim.y * 8 + 4, self.laser.power / 2 + 1)
        love.graphics.setColor(Color.rgb(255, 255, 255))
        love.graphics.setLineWidth(self.laser.power * 0.5)
        love.graphics.circle('fill', self.laser.aim.x * 8 + 4, self.laser.aim.y * 8 + 4, self.laser.power / 2)
        love.graphics.line(self.pos.x, self.pos.y, self.laser.aim.x * 8 + 4, self.laser.aim.y * 8 + 4)
    end
    love.graphics.setLineWidth(1)

    -- inventory hud
    jam.gfx.drawhud(function ()
        local y = 0
        love.graphics.push()
        love.graphics.translate(8, 8)
        for t, i in pairs(self.inventory.items) do
            if love.timer.getTime() < i.disptime then
                local spr = jam.asset('sprite', 'items')
                spr:draw(t + 1, 0, y + 1)
                love.graphics.setColor(Color.rgb(0, 0, 0))
                love.graphics.print(tostring(i.amount), 9, y + 1)
                love.graphics.setColor(Color.rgb(255, 255, 255))
                love.graphics.print(tostring(i.amount), 8, y)
                y = y + 8
            end
        end
        love.graphics.pop()
    end)

    -- placement hud
    jam.gfx.drawhud(function ()
        if love.timer.getTime() < self.laser.hudtime then
            local b = blocks.placeable[self.laser.block]

            do
                if b then
                    local y = 0
                    local h = #b.ingredients * 8

                    love.graphics.setColor(Color.rgb(0, 0, 0))
                    love.graphics.printf(b.name, -9, 41 - h / 2, 96, 'right')
                    love.graphics.setColor(Color.rgb(255, 255, 255))
                    love.graphics.printf(b.name, -10, 40 - h / 2, 96, 'right')

                    for _, i in pairs(b.ingredients) do
                        self.inventory.items[i.id].disptime = love.timer.getTime() + (love.timer.getDelta() + 0.01)

                        local dy = 48 - h / 2 + y
                        local spr = jam.asset('sprite', 'items')
                        spr:draw(i.id + 1, 80, dy + 1)
                        love.graphics.setColor(Color.rgb(0, 0, 0))
                        love.graphics.printf(tostring(i.amt), -17, dy + 1, 96, 'right')
                        love.graphics.setColor(Color.rgb(255, 255, 255))
                        love.graphics.printf(tostring(i.amt), -18, dy, 96, 'right')
                        y = y + 8
                    end
                end
            end

            local draw = function (block, x, y)
                if type(block.place) == 'number' then jam.asset('tileset', 'main'):draw(block.place, x, y)
                elseif type(block.place) == 'table' then
                    local e = block.place.entity
                    local spr = jam.asset('sprite', e.sprite)
                    spr:draw(math.floor(1 + e.sprframe % #spr.quads), x, y)
                end
            end

            local shown = 9
            local fy = 48 - shown / 2 * 8
            for i = 1, shown do
                local n = self.laser.block - math.floor(shown / 2) + (i - 1)
                local b = blocks.placeable[n]
                if b then
                    if n ~= self.laser.block then
                        love.graphics.setShader(jam.asset('shader', 'dock'))
                        draw(b, 88, fy + (i - 1) * 8)
                        love.graphics.setShader()
                    else
                        draw(b, 88, fy + (i - 1) * 8)
                    end
                end
            end
        end
    end)
end

function Player:update(dt)
    -- don't allow the player to move when out of bounds
    self.controllable = self.pos.y > 0 and self.pos.y < self.map.height * 8

    --
    PlatformerPlayer.update(self, dt)
    --

    -- keep the player on top
    if table.find(self.map.instance.entities, self) < #self.map.instance.entities then
        local selfindex = table.find(self.map.instance.entities, self)
        local buffer = self.map.instance.entities[#self.map.instance.entities]
        self.map.instance.entities[#self.map.instance.entities] = self
        self.map.instance.entities[selfindex] = buffer
    end

    local step = dt / 16.666666
    local frame = step * 100

    --- movement

    if love.keyboard.isScancodeDown('lctrl') then
        self.maxspeed[1] = 2
    else
        self.maxspeed[1] = 0.7
    end

    if love.keyboard.isScancodeDown('w') then
        if self.map:get(1, self:mappos()).id == 51 then
            if self.vel.y > -1 then
                self:force(Vector:new(0, frame * -2))
            end
        end
    end

    self.pos:limit(4, self.map.width * 8 - 4, -200, self.map.height * 8 + 200)

    --- animations

    if self.vel.y ~= 0 then self.airtime = self.airtime + step
    else self.airtime = 0 end

    if self.vel.x < 0 then self.facing = 0
    elseif self.vel.x > 0 then self.facing = 3 end

    if self.vel.x < -0.05 or self.vel.x > 0.05 then self.walktime = self.walktime + frame
    else self.walktime = 0 end
    if self.walktime > 2 then self.walktime = 0 end

    self.sprframe = self.facing + self.walktime
    if self.vel.y > 0 then self.sprframe = self.sprframe + 2 - self.walktime end
    if self.vel.y < 0 then self.sprframe = self.facing + 1 end

    --- abilities

    -- laser

    if love.mouse.isDown(1) then self.laser.mode = 'destroy'
    elseif love.mouse.isDown(2) then self.laser.mode = 'place'
    else self.laser.mode = 'none' end
    if math.dist(
            self.pos,
            Vector:point(self.laser.aim.x * 8 + 4, self.laser.aim.y * 8 + 4)) >= 32 then
        self.laser.mode = 'none'
    end
    if self.map:get(1, self.laser.aim.x + 1, self.laser.aim.y + 1).id == 1 then
        if self.laser.mode == 'destroy' then
            self.laser.mode = 'none'
        end
    else
        if self.laser.mode == 'place' then
            self.laser.mode = 'none'
        end
    end

    if self.laser.mode ~= 'none' then self.laser.power = self.laser.power + 4 * frame
    else self.laser.power = 0 end
    self.laser.power = math.min(self.laser.power, 4)

    self.laser.aim:set(
        math.floor(jam.mapmouse.x / 8),
        math.floor(jam.mapmouse.y / 8))

    -- placeable block list
    self.laser.block = math.clamp(self.laser.block, 1, math.max(#blocks.placeable, 1))

    table.clear(blocks.placeable)
    for _, b in pairs(blocks.all) do
        local canplace = (self.inventory:has(unpack(b.ingredients)))
        if canplace then
            table.insert(blocks.placeable, b)
        end
    end

    if self.laser.power >= 4 then
        -- laser: destroy
        if self.laser.mode == 'destroy' then
            local destroyed = self.map:get(1, self.laser.aim.x + 1, self.laser.aim.y + 1)
            local ore = { id = -42 }
            if self.map.mine then ore = self.map:get(2, self.laser.aim.x + 1, self.laser.aim.y + 1) end

            for id, cond in pairs(Item.types) do
                for _, loot in pairs(cond) do
                    for i, v in pairs(loot[1]) do
                        if v == destroyed.id or v == ore.id then
                            for i = 1, love.math.random(loot.amount[1], loot.amount[2]) do
                                jam.spawn(Item:new({
                                    id = id
                                }, self.laser.aim.x * 8 + 4, self.laser.aim.y * 8 + 4, self.map))
                            end
                            break
                        end
                    end
                end
            end

            self.map:set(1, 1, self.laser.aim.x + 1, self.laser.aim.y + 1)
            self.map:set(1, 2, self.laser.aim.x + 1, self.laser.aim.y + 1)
            maps.autoprocess(self.map)

            jam.asset('sound', 'laser-destroy'):stop()
            jam.asset('sound', 'laser-destroy'):play()
        end

        -- laser: place
        if self.laser.mode == 'place' then
            local block = blocks.placeable[self.laser.block]
            if block then
                if (self.inventory:consume(unpack(block.ingredients))) then
                    if type(block.place) == 'number' then
                        self.map:set(block.place, 1, self.laser.aim.x + 1, self.laser.aim.y + 1)
                        maps.autoprocess(self.map)
                    elseif type(block.place) == 'table' then
                        self.map:set(block.place.block, 1, self.laser.aim.x + 1, self.laser.aim.y + 1)
                        self.map:spawn(
                            block.place.entity:new({
                                    block = block
                                },
                                self.laser.aim.x * 8 + 4,
                                self.laser.aim.y * 8 + 4,
                                self.map))
                        maps.autoprocess(self.map)
                    end
                    jam.asset('sound', 'laser-place'):stop()
                    jam.asset('sound', 'laser-place'):play()
                end
            end
        end
    end

    --- mines

    if self.pos.y > self.map.height * 8 and self.pos.y < (self.map.height + 1) * 8 and self.vel.y > 0 then
        if not self.map.mine then
            jam.gfx.wipe('radial_wipe', 0.5, true, { smoothness = 0.1, invert = true }, function ()
                blankwait(0.1, 'game', function ()
                    mines.enter(math.floor(self.pos.x / 8))
                end)
            end)
        else
            jam.gfx.wipe('radial_wipe', 0.5, true, { smoothness = 0.1, invert = true }, function ()
                blankwait(0.1, 'game', function ()
                    currentmap = jam.asset('map', 'planet')
                    currentmap.player.map = currentmap
                    currentmap.player.pos:set(mines.x * 8 + 4, -40)
                    currentmap.player.pos.y = -40
                    mines.exit()
                end)
            end)
        end
    end
    if self.map.mine then
        if self.laser.power > 0 then
            if self.laser.mode == 'destroy' then
                mines.light(
                    self.laser.aim.x * 8 + 4, self.laser.aim.y * 8 + 4, self.laser.power * 0.1, Color.rgb(255, 0, 68))
            elseif self.laser.mode == 'place' then
                mines.light(
                    self.laser.aim.x * 8 + 4, self.laser.aim.y * 8 + 4, self.laser.power * 0.1, Color.rgb(44, 232, 245))
            end
        end

        mines.light(self.pos.x, self.pos.y, 0.3, Color.rgb(255, 255, 255))

        if self.pos.y < -6 and self.vel.y < 0 then
            jam.gfx.wipe('radial_wipe', 0.5, true, { smoothness = 0.1, invert = true }, function ()
                blankwait(0.1, 'game', function ()
                    currentmap = jam.asset('map', 'planet')
                    currentmap.player.map = currentmap
                    currentmap.player.pos:set(mines.x * 8 + 4, (currentmap.height + 2) * 8)
                    currentmap.player.vel:set(0, -50)
                    currentmap.player.cutscenetime = 0.2
                    mines.exit()
                end)
            end)
            self.immobiletime = 0.1
            self.vel.y = 0
        end
    end

    --- camera

    self.screen = Vector:new(math.floor(self.pos.x / 96), 0)
    self.map.scroll:set(
        math.clamp(math.lerp(
            self.map.scroll.x,
            self.screen.x * 96 + (jam.mouse.x - 48) * 0.2,
            1.0 * frame), 0, (self.map.width - 12) * 8),
        math.clamp(math.lerp(self.map.scroll.y, self.pos.y - 96 / 2, 1.5 * frame), 0, (self.map.height - 12) * 8))

    --
    self.laser.scrolloff = self.laser.scrolloff - dt
end

function Player:collideEntity(ent)
    if ent.supertype == 'item' then
        if self.inventory:put({ id = ent.id, amt = ent.amount }) then jam.despawn(ent) end
        jam.asset('sound', 'pickup'):stop()
        jam.asset('sound', 'pickup'):play()
    end
end

function Player:wheelmoved(x, y)
    if self.laser.scrolloff <= 0 then
        self.laser.hudtime = love.timer.getTime() + 4
        if y > 0 then
            if self.laser.block > 1 then self.laser.block = self.laser.block - 1 end
        elseif y < 0 then
            if self.laser.block < #blocks.placeable then self.laser.block = self.laser.block + 1 end
        end
        jam.asset('sound', 'pick'):stop()
        jam.asset('sound', 'pick'):play()
    end
end
