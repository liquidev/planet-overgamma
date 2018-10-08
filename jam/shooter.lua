require 'jam/entity'

Bullet = Entity:extend()
Bullet.__index = Bullet

Bullet.sprite = 'bullet'

Bullet.angle = 0
Bullet.spread = 0
Bullet.speed = 5
Bullet.damage = 0.3

function Bullet:init()
    self.hitboxsize = { 4, 4 }

    angle = self.angle + love.math.randomNormal(self.spread)
    self:force(Vector:new(math.sin(angle) * self.speed, math.cos(angle) * self.speed))
end

function Bullet:draw()
    self:drawSprite()
    self.rotation = -self.angle + math.pi / 2
    self.sprframe = self.sprframe + love.math.random(1, 2)
end

function Bullet:collideTile()
    self.remove = true
end

function Bullet:collideEntity(entity)
    if entity.supertype ~= 'player' then self.remove = true end
    if entity.supertype == 'enemy' then
        entity:damage(self.damage)
    end
end

ShooterPlayer = Entity:new(nil, 0, 0, nil)
ShooterPlayer.__index = ShooterPlayer
ShooterPlayer.supertype = 'player'

ShooterPlayer.sprite = 'player'

ShooterPlayer.maxhealth = 10
ShooterPlayer.accel = 20
ShooterPlayer.speed = 80
ShooterPlayer.decel = 0.75
ShooterPlayer.bullettype = Bullet
ShooterPlayer.immunity = 0.5

function ShooterPlayer:init()
    self.health = self.maxhealth
    self.immuneTime = love.timer.getTime()

    self.texts = {

    }
end

function ShooterPlayer:draw()
    self:drawSprite()

    if not self.texts.hp then self.texts.hp = love.graphics.newText(jam.assets.fonts['main']) end

    jam.assets.sprites['bar-health']:draw(1, 0, 0)
    love.graphics.setScissor(0, 0, 48 * (self.health / self.maxhealth), 8)
    jam.assets.sprites['bar-health']:draw(2, 0, 0)
    love.graphics.setScissor()
    self.texts.hp:set(self.health..'/'..self.maxhealth)
    love.graphics.setColor(0, 0, 0)
    love.graphics.draw(self.texts.hp, 2, 1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.texts.hp, 1, 0)
end

function ShooterPlayer:update(dt)
    step = dt / 1.666666
    frame = step * 100

    local key = love.keyboard.isScancodeDown

    if not self.ai then
        if key('w') then self:force(Vector:new(0, -self.accel * step)) end
        if key('s') then self:force(Vector:new(0, self.accel * step)) end
        if key('a') then self:force(Vector:new(-self.accel * step, 0)) end
        if key('d') then self:force(Vector:new(self.accel * step, 0)) end
    end

    self.rotation = math.atan2(jam.mouse.y - self.pos.y, jam.mouse.x - self.pos.x)

    self.vel:mul(self.decel)

    if (math.abs(self.vel.x) + math.abs(self.vel.y)) > 0.2 then
        self.sprframe = self.sprframe + 0.25 * frame
    else
        self.sprframe = 0
    end

    self:physics(dt)
end

function ShooterPlayer:damage(hp)
    if love.timer.getTime() > self.immuneTime + self.immunity then
        self.health = self.health - hp
        self.health = math.max(0, self.health)
        if self.health <= 0 then
            self.remove = true
        end
        self.immuneTime = love.timer.getTime()
        jam.assets.sounds['hurt']:play()
        jam.shake(30, 5)
    end
end

function ShooterPlayer:shoot()
    bullet = self.bullettype:new({
        angle = -math.atan2(jam.mouse.y - self.pos.y, jam.mouse.x - self.pos.x) + math.pi / 2
    }, self.pos.x, self.pos.y, self.map)
    jam.assets.sounds['shoot']:stop()
    jam.assets.sounds['shoot']:play()
    jam.spawn(bullet)
end

function ShooterPlayer:mousepressed()
    self:shoot()
end

ShooterEnemy = Entity:new(nil, 0, 0, nil)
ShooterEnemy.__index = ShooterEnemy
ShooterEnemy.supertype = 'enemy'

ShooterEnemy.maxhealth = 10
ShooterEnemy.speed = 0.5

function ShooterEnemy:init()
    self.sprite = 'enemy'

    self.health = self.maxhealth

    self.target = nil
    self.ai = {
        state = 'towards-player',
        blinduntil = 0
    }
end

function ShooterEnemy:draw()
    self:drawSprite()

    jam.assets.sprites['bar-health-small']:draw(1, self.pos.x - 6, self.pos.y - 8)
    love.graphics.setScissor(self.pos.x - 6, self.pos.y - 8, 12 * (self.health / self.maxhealth), 4)
    jam.assets.sprites['bar-health-small']:draw(2, self.pos.x - 6, self.pos.y - 8)
    love.graphics.setScissor()
end

function ShooterEnemy:update(dt)
    Entity.update(self, dt)
    step = dt / 1.666666
    frame = step * 100

    self.map:eachEntity(function (entity)
        if entity.supertype == 'player' then
            self.target = entity
        end
    end)
    if not self.target then self.remove = true
    else
        if self.ai.state == 'towards-player' then
            self.rotation = math.atan2(self.target.pos.y - self.pos.y, self.target.pos.x - self.pos.x)
        elseif self.ai.state == 'check-tiles' then
            local x = math.floor(self.pos.x / Map.tilesize[1])
            local y = math.floor(self.pos.y / Map.tilesize[2])
            if     self.map:getSolid(x - 1, y) then self.rotation = 0; self:blind(0.5)
            elseif self.map:getSolid(x + 1, y) then self.rotation = math.pi; self:blind(0.5)
            elseif self.map:getSolid(x, y - 1) then self.rotation = math.pi / 2; self:blind(0.5)
            elseif self.map:getSolid(x, y + 1) then self.rotation = math.pi / 4 * 3; self:blind(0.5)
            else self:blind(0.25)
            end
        elseif self.ai.state == 'blind' then
            if love.timer.getTime() > self.ai.blinduntil then self.ai.state = 'towards-player' end
        end
        self.vel:set(math.cos(self.rotation) * self.speed, math.sin(self.rotation) * self.speed)

        if (math.abs(self.vel.x) + math.abs(self.vel.y)) > 0.2 then
            self.sprframe = self.sprframe + 0.25 * frame
        else
            self.sprframe = 0
        end
    end
end

function ShooterEnemy:damage(hp)
    self.health = self.health - hp
    self.health = math.max(0, self.health)
    if self.health <= 0 then
        self.remove = true
    end
    jam.assets.sounds['hurt-enemy']:play()
    jam.shake(30, 2)
end

function ShooterEnemy:blind(time)
    self.ai.blinduntil = love.timer.getTime() + time
    self.ai.state = 'blind'
end

function ShooterEnemy:collideTile(tile)
    self.ai.state = 'check-tiles'
end

function ShooterEnemy:collideEntity(entity)
    if entity.supertype == 'player' then
        entity:damage(2)
    end
end
