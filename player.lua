SpamBullet = Bullet:extend()
SpamBullet.__index = SpamBullet

SpamBullet.sprite = 'bullet1'

SpamalityPlayer = ShooterPlayer:extend()
SpamalityPlayer.__index = SpamalityPlayer

SpamalityPlayer.bullettype = SpamBullet

function SpamalityPlayer:init()
    ShooterPlayer.init(self)

    self.spamality = 0
    self.spamlevel = 0
    self.spamtarget = 30
end

function SpamalityPlayer:draw()
    ShooterPlayer.draw(self)

    jam.assets.sprites['bar-spamality']:draw(1, 80, 0)
    love.graphics.setScissor(80, 0, 48 * math.max(0, self.spamality / self.spamtarget), 8)
    jam.assets.sprites['bar-spamality']:draw(2, 80, 0)
    love.graphics.setScissor()
    self.texts.hp:set('LV '..self.spamlevel)
    love.graphics.setColor(0, 0, 0)
    love.graphics.draw(self.texts.hp, 80 + 2, 1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.texts.hp, 80 + 1, 0)
end

function SpamalityPlayer:update(dt)
    ShooterPlayer.update(self, dt)

    self.spamality = self.spamality - dt * (0.2 + self.spamlevel * 0.25)
    if self.spamality < 0 then self.spamlevel = 0 end

    if self.spamlevel >= 10 then
        if self.health < self.maxhealth then
            self.health = self.health + self.spamlevel * 0.01 * dt
            self.health = math.min(10, self.health)
        end
    end
end

function SpamalityPlayer:shoot()
    bulletlvl = 1
    bulletspread = 0.1
    bulletdmg = 0.3 + 0.4 * (self.spamlevel)
    if self.spamlevel >= 3 then
        bulletlvl = 2
        bulletdmg = bulletdmg + 1
    end
    if self.spamlevel >= 5 then
        bulletspread = 0.05
    end
    if self.spamlevel >= 7 then
        bulletlvl = 3
        bulletdmg = bulletdmg + 3
    end

    bullet = self.bullettype:new({
        sprite = 'bullet'..bulletlvl,

        angle = -math.atan2(jam.mouse.y - self.pos.y, jam.mouse.x - self.pos.x) + math.pi / 2,
        spread = bulletspread,
        damage = bulletdmg
    }, self.pos.x, self.pos.y, self.map)
    jam.assets.sounds['shoot']:stop()
    jam.assets.sounds['shoot']:play()
    jam.spawn(bullet)
end

function SpamalityPlayer:spam()
    if self.spamality < 0 then
        self.spamality = 0
    end
    self.spamality = self.spamality + 1
    if self.spamality >= self.spamtarget then
        jam.assets.sounds['powerup']:stop()
        jam.assets.sounds['powerup']:play()
        self.spamlevel = self.spamlevel + math.floor(self.spamality / self.spamtarget)
        self.spamality = self.spamlevel
        self.spamtarget = self.spamtarget + 10
    end
end

function SpamalityPlayer:mousepressed()
    self:shoot()
    self:spam()
end

SpamalityEnemy = ShooterEnemy:extend()
SpamalityEnemy.__index = SpamalityEnemy

function SpamalityEnemy:death()
    print('death')
    self.map:eachEntity(function (entity)
        if entity.supertype == 'player' then
            entity.spamality = entity.spamality + wave * 10
            print(entity.spamality)
        end
    end)
end
