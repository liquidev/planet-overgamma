-- Item entity. This is what gets spawned in the world when items are dropped.

local graphics = love.graphics
local lmath = love.math

local common = require "common"
local Entity = require "world.entity"
local game = require "game"
local Vec = require "vec"

local lerp = common.lerp

---

local Item = Entity:inherit()

-- Coefficient of friction against the ground.
local friction = 0.8

-- Initializes a new item from the given item stack.
function Item:init(world, stack)
  self.body = world:newBody(Vec(6, 6), 0.005 + lmath.random() * 0.001, self)
  self.body.elasticity = 0.5
  self.stack = stack
end

-- Randomizes the item's velocity to fly in a random direction.
-- This is meant to use as a chain method during construction, so this returns
-- self.
function Item:randomizeVelocity(magnitudeMin, magnitudeMax, angleMin, angleMax)
  local angle = lerp(angleMin, angleMax, lmath.random())
  local magnitude = lerp(lmath.random(), magnitudeMin, magnitudeMax)
  local x, y = math.cos(angle) * magnitude, math.sin(angle) * magnitude
  self.body.velocity:set(x, y)
  return self
end

-- Removes the specified item amount from the item entity, returns the actual
-- amount that was removed if amount exceeds how much material the item stack
-- holds.
-- If the amount of items in the entity reaches 0, the entity is dropped.
function Item:take(amount)
  local remove = math.min(amount, self.stack.amount)
  self.stack.amount = self.stack.amount - remove
  if self.stack.amount <= 0 then
    self.body:drop()
    self:drop()
  end
  return remove
end

-- Ticks the item.
function Item:update()
  -- friction against the ground
  if self.body.collidingWith.top then
    self.body.velocity:mul(friction, 1)
  end
end

-- Draws the item.
function Item:draw(alpha)
  -- This currently doesn't do any batching, as there aren't *that* many items
  -- + the fact that items clump to each other on contact.
  local quad = game.items[self.stack.id].quad
  local position = self.body:interpolatePosition(alpha)
  local center = position + self.body.size / 2
  local _, _, width, height = quad:getViewport()
  local spritePosition = center - Vec(width, height) / 2
  graphics.draw(game.itemAtlas.image, quad, spritePosition:xy())
end

return Item

