wave = 1

SpamalitySpawner = Entity:extend()
SpamalitySpawner.__index = SpamalitySpawner
SpamalitySpawner.supertype = 'spawner'
SpamalitySpawner.name = 'Spawner'

SpamalitySpawner.sprite = 'spawner'

SpamalitySpawner.interval = 2

function SpamalitySpawner:init()
    self.time = 0
    self.buffer = 1
    self:nextwave()
end

function SpamalitySpawner:nextwave()
    self.buffer = wave
    self.interval = self.interval - 0.1
end

function SpamalitySpawner:spawn()
    if self.buffer > 0 then
        self.buffer = self.buffer - 1
        jam.spawn(ShooterEnemy:new({
            maxhealth = wave * 10,
            speed = 0.3 + wave * 0.025
        }, self.pos.x, self.pos.y, self.map))
    end
end

function SpamalitySpawner:update(dt)
    Entity.update(self, dt)

    self.sprframe = self.sprframe + dt * 8

    self.time = self.time + dt
    if self.time > self.interval then
        self:spawn()
        self.time = 0
    end
end
