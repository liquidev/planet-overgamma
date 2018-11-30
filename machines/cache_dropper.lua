local CacheDropper = Machine:extend('machine.cachedropper', 'Cache Dropper')
CacheDropper.__index = CacheDropper

CacheDropper.sprframe = 9
CacheDropper.categories = { '-item' }

function CacheDropper:init()
    Machine.init(self)

    self.time = 0
    self.speed = 0.5
end

function CacheDropper:update(dt)
    Machine.update(self, dt)

    if self.dropfrom and love.mouse.isDown(2) then
        if self:hitbox():has(jam.mapmouse) then
            self.time = self.time + dt
            if self.time > self.speed then
                self.time = 0
                self.speed = self.speed / 1.35
                if self.dropfrom.owner.supertype == 'machine.cache' then
                    if self.dropfrom:has({ id = self.dropfrom.owner.item, amt = 1 }) then
                        self:iout(self.dropfrom.owner.item, 1)
                        self.dropfrom:consumeall({ id = self.dropfrom.owner.item, amt = 1 })
                    end
                end
            end
        end
    else
        self.time = 0
        self.speed = 0.5
    end
end

function CacheDropper:interact()
    self.time = 1
end

function CacheDropper:onitems(inv)
    self.dropfrom = inv
end

return CacheDropper
