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
local speed = 0.25
-- The player's deceleration factor.
local decel = 0.8
-- The amount of ticks the player jumps for.
local jumpTicks = 15
-- The amount of ticks during which the player can start a jump after falling.
local coyoteTime = 10

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

  self.jumpTimer = 0
  self.coyoteTimer = 0
end

-- Returns whether the player is falling.
function Player:isFalling()
  return self.body.velocity.y > 0.01
end

-- Returns the animation state of the player ("idle" | "walk" | "fall")
function Player:animationState()
  if self.body.velocity.y < -0.01 then
    return "walk"
  elseif self:isFalling() then
    return "fall"
  elseif self.walkTimer % 20 > 10 then
    return "walk"
  else
    return "idle"
  end
end

-- Returns whether the player can jump.
function Player:canJump()
  return self.body.collidingWith.top or self.coyoteTimer > 0
end

-- Ticks the player.
function Player:update()
  --
  -- Controls
  --

  -- sideways movement
  if input:keyDown('a') then
    self.body:applyForce(Vec(-speed, 0))
    self.facing = "left"
  end
  if input:keyDown('d') then
    self.body:applyForce(Vec(speed, 0))
    self.facing = "right"
  end

  -- jumping

  if self.body.collidingWith.top then
    self.coyoteTimer = coyoteTime
  end
  self.coyoteTimer = self.coyoteTimer - 1

  if self:canJump() and input:keyJustPressed("space") then
    self.jumpTimer = jumpTicks
    self.body.velocity.y = 0
  end
  if not input:keyDown("space") then
    self.jumpTimer = 0
  end
  if self.jumpTimer > 0 then
    local jumpForce = Vec(0, -(self.jumpTimer / jumpTicks)^6 * 1.5)
    self.jumpTimer = self.jumpTimer - 1
    self.body:applyForce(jumpForce)
  end

  -- deceleration
  self.body.velocity:mul(Vec(decel, 1))

  --
  -- Animation timers
  --
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
  self._camera.pan = self:interpolatePosition(alpha) + self.body.size / 2
  return self._camera
end

return Player
