require 'jam/entity'

PlatformerPlayer = Entity:extend('player', 'Player')
PlatformerPlayer.__index = PlatformerPlayer

PlatformerPlayer.sprite = 'player'

PlatformerPlayer.gravity = Vector:new(0, 75)
PlatformerPlayer.accel = 200
PlatformerPlayer.decel = 0.8
PlatformerPlayer.maxspeed = { 0.7, 2 }
PlatformerPlayer.jumpstrength = 1500
PlatformerPlayer.jumpsustain = 0.7
PlatformerPlayer.airtime = 0
PlatformerPlayer.controllable = true

function PlatformerPlayer:init()
    self.hitboxsize = { 8, 8 }

    self.facing = 3
    self.walktime = 0
    self.cutscenetime = 0

    self.jumpsustend = 0
end

function PlatformerPlayer:update(dt)
    local step = dt / 16.666666
    local frame = step * 100

    local key = love.keyboard.isScancodeDown

    self.cutscenetime = self.cutscenetime - dt

    if self.controllable and self.cutscenetime <= 0 then
        if key('a') then self:force(Vector:new(-self.accel * step, 0)) end
        if key('d') then self:force(Vector:new(self.accel * step, 0)) end
        if key('space') then
            if love.timer.getTime() < self.jumpsustend then
                local sustainstrength = (self.jumpsustend - love.timer.getTime()) / self.jumpsustain
                self.vel.y = -self.jumpstrength * sustainstrength * step
            end
        end
    end

    self.vel
        :limit(-self.maxspeed[1], self.maxspeed[1], -self.maxspeed[2], self.maxspeed[2])
        :mul(self.decel, 1)

    self:force(self.gravity:copy():mul(step))

    self:physics(dt)
end

function PlatformerPlayer:keypressed(_, scancode)
    if scancode == 'space' and (self.vel.y == 0 or self.airtime > 0 and self.airtime < 0.0075) then
        jam.asset('sound', 'jump'):play()
        self.jumpsustend = love.timer.getTime() + self.jumpsustain
    end
end
