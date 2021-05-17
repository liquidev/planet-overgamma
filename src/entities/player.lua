-- Player controls, world interaction, etc.

local graphics = love.graphics
local timer = love.timer

local rgba = love.math.colorFromBytes

local Camera = require "camera"
local common = require "common"
local Entity = require "world.entity"
local game = require "game"
local Item = require "entities.item"
local items = require "items"
local ItemStorage = require "item-storage"
local Vec = require "vec"
local World = require "world"

local input = game.input
local Chunk = World.Chunk

local mbLeft = input.mbLeft
local quantity = items.quantity
local white = common.white

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
-- The speed at which the laser charges up.
local laserChargeRate = 0.03

-- Initializes the player with the given world.
function Player:init(world)
  assert(world ~= nil)

  self._camera = Camera:new()
  self.world = world
  self.body = world:newBody(Vec(8, 6), 0.0075, self)
  function self.body.onCollisionWithBody(body)
    self:collisionWithBody(body)
  end

  -- For now this is hardcoded to blue, later I might add player color selection
  -- but now is not the time.
  self.sprites = game.playerSprites.blue
  self.facing = "right" -- "right" | "left"
  self.walkTimer = 0

  self.jumpTimer = 0
  self.coyoteTimer = 0

  self.laserEnabled = false
  self.laserMode = "none" -- "none" | "destroy" | "construct"
  self.laserCharge = 0
  self.laserMaxCharge = 2
  self.laserRange = 5 * Chunk.tileSize

  self.inventory = ItemStorage:new { size = 2560 }
  self.showStacks = {}
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
  -- Movement
  --

  -- walkin'
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
    self.coyoteTimer = 0
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
  -- Animation
  --

  -- timers
  if math.abs(self.body.velocity.x) > 0.01 then
    self.walkTimer = self.walkTimer + 1
  else
    self.walkTimer = 0
  end

  -- face the player to where the laser is pointed
  if self.laserEnabled then
    local direction = (self:laserPosition() - self.body.position).x
    self.facing = (direction < 0) and "left" or "right"
  end

  --
  -- Item magnet
  --

  local position = self.body.position + self.body.size / 2
  for _, entity in ipairs(self.world.entities) do
    if entity:of(Item) then
      local target = position - entity.body.size / 2
      local delta = self.world:shortestDelta(entity.body.position, target)
      local distance = delta:len()
      local strength = math.min((math.max(0, 48 - distance) / 48) * 0.3, 4)
      local pull = delta:normalized() * strength
      entity.body:applyForce(pull)
    end
  end
end

function Player:prePhysicsUpdate()
  --
  -- Laser
  --

  -- modes
  self.laserEnabled = false
  if input:mouseDown(mbLeft) then
    self.laserMode = "destroy"
    self.laserEnabled = true
  end

  -- charging
  if self.laserEnabled then
    local coeff =
      (self.laserMaxCharge - self.laserCharge) / self.laserMaxCharge *
      laserChargeRate
    self.laserCharge = self.laserCharge + self.laserMaxCharge * coeff
  else
    self.laserCharge = self.laserCharge * 0.6
  end

  -- destruction laser
  if self.laserMode == "destroy" then
    local target = self:laserTarget()
    local block = self.world:breakBlock(target, self.laserCharge)
    if block ~= nil then
      self.laserCharge = self.laserCharge - block.hardness * 2
    end
  end

  -- sanitize the charge value
  self.laserCharge = math.max(self.laserCharge, 0)
end

-- Handles collision with another body.
function Player:collisionWithBody(body)
  if body.owner == nil or not body.owner:of(Entity) then return end

  local entity = body.owner
  if entity:of(Item) then
    entity:take(self:takeItem(entity.stack))
  end
end

-- Attempts to take items from an item stack into the player's inventory,
-- according to the rules in ItemStorage:take.
-- Returns the actual amount of items taken.
function Player:takeItem(idOrStack, amount)
  local id
  if type(idOrStack) == "table" then id = idOrStack.id
  else id = idOrStack end
  self.showStacks[id] = timer.getTime() + 3
  return self.inventory:put(idOrStack, amount)
end

-- Interpolates the position of the player.
function Player:interpolatePosition(alpha)
  return self.body:interpolatePosition(alpha)
end

-- Returns the unbounded position of the mouse.
function Player:mousePosition()
  return self._camera:toWorldSpace(input.mouse)
end

-- Returns the position the player's pointing at with the laser.
function Player:laserPosition()
  -- This clamps the laser position to the maximum range.
  local center = self.body:center()
  local direction, len = (self:mousePosition() - center):normalized()
  len = math.min(len, self.laserRange)
  return center + direction * len
end

-- Returns the block the laser is targeting.
local unboundedTarget = true -- constant used as an argument to laserTarget
function Player:laserTarget(unbounded)
  local tile
  if unbounded then
    tile = self:mousePosition()
  else
    tile = self:laserPosition()
  end
  tile = tile / Chunk.size
  tile.x = math.floor(tile.x)
  tile.y = math.floor(tile.y)
  return tile
end

-- The colors of the laser core and glows.
local laserColors = {
  -- Glow colors
  none      = { rgba(0, 0, 0) },
  destroy   = { rgba(235, 19, 74) },
  construct = { rgba(0, 234, 255) },
  -- Core color
  core      = { rgba(255, 255, 255) },
}

-- Draws a laser.
local function drawLaser(from, to, thickness, color)
  graphics.setLineWidth(thickness)
  graphics.setColor(color)
  graphics.line(from.x, from.y, to.x, to.y)
  graphics.circle("fill", from.x, from.y, thickness / 2)
  graphics.circle("fill", to.x, to.y, thickness)
  graphics.setColor(white)
end

-- Renders the player.
function Player:draw(alpha)
  graphics.push("all")
  graphics.setLineStyle("rough")

  -- sprite
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

  -- laser
  local laserTarget = self:laserTarget() * Chunk.tileSize
  local unbLaserTarget = self:laserTarget(unboundedTarget) * Chunk.tileSize
  graphics.rectangle(
    "line",
    laserTarget.x, laserTarget.y,
    Chunk.tileSize, Chunk.tileSize
  )
  graphics.setLineWidth(1 / self._camera.scale)
  graphics.rectangle(
    "line",
    unbLaserTarget.x, unbLaserTarget.y,
    Chunk.tileSize, Chunk.tileSize
  )
  if self.laserCharge > 0.01 then
    local color = laserColors[self.laserMode]
    local thickness = self.laserCharge
    local glowThickness = (thickness < 1) and (3 * thickness) or (thickness + 2)
    local laserPosition = self:laserPosition()
    drawLaser(center, laserPosition, glowThickness, color)
    drawLaser(center, laserPosition, thickness, laserColors.core)
  end

  graphics.pop()
end

-- Updates and returns the player's camera.
function Player:camera(alpha)
  self._camera.pan = self:interpolatePosition(alpha) + self.body.size / 2
  self._camera:updateViewport(Vec(graphics.getDimensions()))
  return self._camera
end

local usageBarColors = {
  green  = { rgba(127, 236, 82) },
  yellow = { rgba(255, 195, 31) },
  red    = { rgba(251, 78, 78) },
}

-- Draws the player's HUD.
function Player:ui()
  local sx, sy = 16, 16

  local ix, iy = sx, sy + 20
  local y = 0
  local shownItems = false
  for id, time in pairs(self.showStacks) do
    if timer.getTime() < time then
      local amount = self.inventory:get(id)
      local quad = game.items[id].quad
      local _, _, _, height = quad:getViewport()
      graphics.draw(game.itemAtlas.image, quad, ix, iy + y, 0, 3)

      local qty = quantity(amount)
      graphics.print(qty, ix + 32, iy + y)

      shownItems = true
      y = y + height + 24
    end
  end

  if shownItems then
    local barw = 256
    local full = self.inventory:occupied() / self.inventory.size
    graphics.setColor(rgba(255, 255, 255, 32))
    graphics.rectangle("fill", sx, sy, barw, 4)
    local color = usageBarColors.green
    if full > 0.60 then color = usageBarColors.yellow end
    if full > 0.80 then color = usageBarColors.red end
    graphics.setColor(color)
    graphics.rectangle("fill", sx, sy, barw * full, 4)
    graphics.setColor(white)
  end
end

return Player
