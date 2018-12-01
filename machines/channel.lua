local Channel = Machine:extend('machine.channel', 'Channel')
Channel.__index = Channel

Channel.sprframe = 20
Channel.categories = { '*inv', '*out', '+item', '-item' }
Channel.hassettings = true

Channel.invsettings = { {}, 64 }

Channel.channels = {}

function Channel:init()
    Machine.init(self)

    self.time = 0

    self:set(1)
end

function Channel:draw()
    Machine.draw(self)

    if self:hitbox():has(jam.mapmouse) then
        love.graphics.setColor(Color.rgb(0, 0, 0))
        love.graphics.printf(self.channelid, self.pos.x - 3, self.pos.y - 3, 8, 'center')
        love.graphics.setColor(Color.rgb(255, 255, 255))
        love.graphics.printf(self.channelid, self.pos.x - 4, self.pos.y - 4, 8, 'center')
    end
end

function Channel:tick(dt)
    Machine.tick(self, dt)

    self.time = self.time + dt

    if self.time > 0.5 then
        self:eachConnected(function (m)
            m:iaccept(self.inventory)
        end)
        self.time = 0
    end
end

function Channel:iaccept(inv)
    if inv.owner and inv.owner.__index ~= Player then
        for t, i in pairs(self.inventory.items) do
            local amount = inv:consumeall({ id = t, amt = self.inventory:free(t) })
            self.inventory:put({ id = t, amt = amount })
        end
    end
end

function Channel:set(ch)
    if not Channel.channels[ch] then
        Channel.channels[ch] = Inventory:new({}, 64)
    end
    self.channelid = ch
    self.channel = Channel.channels[self.channelid]
    self.inventory = self.channel
end

function Channel:edit(value)
    self:set((self.channelid + value) % 100)
end

return Channel
