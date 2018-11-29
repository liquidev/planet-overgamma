local Cache = Machine:extend('machine.cache', 'Cache')
Cache.__index = Cache

Cache.sprframe = 8
Cache.categories = { '*inv', '*out' }

Cache.hassettings = true

Cache.invsettings = { {}, 128 }

function Cache:init()
    Machine.init(self)

    self.item = 0
    self.time = 0

    self.bars = {
        amount = { color = {Color.rgb(123, 229, 60)}, progress = 0.0 }
    }
end

function Cache:draw()
    Machine.draw(self)

    jam.asset('sprite', 'items'):draw(self.item + 1, self.pos.x - 3, self.pos.y - 3)
end

function Cache:tick(dt)
    Machine.tick(self, dt)

    self.time = self.time + dt

    if self.time > 0.75 then
        self:eachConnected(function (m)
            m:iaccept(self.inventory)
        end)
        self.time = 0
    end

    table.clear(self.bars)
    for t, i in pairs(self.inventory.items) do
        if i.amount > 0 then
            self.bars[t] = {
                color = {Color.rgb(123, 229, 60)},
                progress = i.amount / 128
            }
        end
    end
end

function Cache:iaccept(inv)
    if inv.owner and inv.owner.__index == Player then
        local amount = self.inventory:free(self.item)
        self.inventory:put({ id = self.item, amt = inv:consumeall({ id = self.item, amt = amount }) })
    else
        for t, i in pairs(self.inventory.items) do
            local amount = inv:consumeall({ id = t, amt = self.inventory:free(t) })
            self.inventory:put({ id = t, amt = amount })
        end
    end
end

function Cache:edit(value)
    self.item = (self.item + value) % (table.len(self.inventory.items))
end

return Cache
