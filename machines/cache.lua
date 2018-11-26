local Cache = Machine:extend('machine.cache', 'Cache')
Cache.__index = Cache

Cache.sprframe = 8
Cache.hassettings = true
Cache.categories = { 'inventory' }

function Cache:init()

end

function Cache:tick(dt)
    Machine.tick(self, dt)
end

return Cache
