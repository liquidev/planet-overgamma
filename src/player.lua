-- Player controls, world interaction, etc.

local graphics = love.graphics

local Camera = require "camera"
local Entity = require "world.entity"
local game = require "game"
local Vec = require "vec"

local input = game.input

---

local Player = Entity:inherit()

-- The player's walking speed.
Player.speed = 0.25
-- The player's deceleration factor.
Player.decel = 0.8

-- Initializes the player with the given world.
function Player:init(world)
  assert(world ~= nil)

  self._camera = Camera:new()
  self.world = world
  self.body = world:newBody(Vec(8, 6), 0.0075)

  -- For now this is hardcoded to blue, later I might add player color selection
  -- but now is not the time.
  self.sprites = game.playerSprites.blue
  self.facing = "right" -- "right" | "left"
  self.walkTimer = 0
end

-- Returns the animation state of the player ("idle" | "walk" | "fall")
function Player:animationState()
  if self.body.velocity.y < -0.01 then
    return "walk"
  elseif self.body.velocity.y > 0.01 then
    return "fall"
  elseif self.walkTimer % 20 > 10 then
    return "walk"
  else
    return "idle"
  end
end

-- Ticks the player.
function Player:update()
  -- controls
  if input:keyDown('a') then
    self.body:applyForce(Vec(-self.speed, 0))
    self.facing = "left"
  end
  if input:keyDown('d') then
    self.body:applyForce(Vec(self.speed, 0))
    self.facing = "right"
  end
  if self.body.collidingWith.top and input:keyJustPressed("space") then
    self.body:applyForce(Vec(0, -3.5))
  end
  self.body.velocity:mul(Vec(self.decel, 1))

  -- animation
  if math.abs(self.body.velocity.x) > 0.01 then
    self.walkTimer = self.walkTimer + 1
  else
    self.walkTimer = 0
  end
end

-- Interpolates the position of the player.
function Player:interpolatePosition(alpha)
  return self.body:interpolatePosition(alpha)
end

-- Renders the player.
function Player:draw(alpha)
  local position = self:interpolatePosition(alpha)
  local sprite = self.sprites[self:animationState()]
  local spriteSize = Vec(sprite:getDimensions())
  local center = position + self.body.size / 2
  local x, y = (center - spriteSize / 2):xy()
  local scale = (self.facing == "left") and -1 or 1
  if scale == -1 then
    x = x + spriteSize.x
  end
  graphics.draw(self.sprites[self:animationState()], x, y, 0, scale, 1)
end

-- Updates and returns the player's camera.
function Player:camera(alpha)
  self._camera.pan = self:interpolatePosition(alpha)
  return self._camera
end

return Player
