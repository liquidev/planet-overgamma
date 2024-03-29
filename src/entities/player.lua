-- Player controls, world interaction, etc.

local graphics = love.graphics
local timer = love.timer

local rgba = love.math.colorFromBytes

local Camera = require "camera"
local common = require "common"
local Entity = require "world.entity"
local game = require "game"
local ggraphics = require "ggraphics"
local Item = require "entities.item"
local items = require "items"
local ItemStorage = require "item-storage"
local Object = require "object"
local recipes = require "recipes"
local Registry = require "registry"
local tr = require("i18n").tr
local Vec = require "vec"
local World = require "world"

local icons = game.icons
local input = game.input

local mbLeft, mbRight = input.mbLeft, input.mbRight

local quantity = items.quantity

local white = common.white

local Chunk = World.Chunk

---

--- @class Player: Entity
local Player = Entity:inherit()

--- The player's walking speed.
local speed = 0.25
--- The player's deceleration factor.
local decel = 0.8
--- The amount of ticks the player jumps for.
local jumpTicks = 15
--- The amount of ticks during which the player can start a jump after falling.
local coyoteTime = 10
--- The speed at which the laser charges up.
local laserChargeRate = { destroy = 0.03, construct = 0.075 }

--- Initializes the player with the given world.
--- @param world World
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
  self.recipes = {}
  self.recipeTargets = { "portAssembler.1" }
  self.selectedRecipe = 1
  self.portAssemblerTier = 1
  self.recipeDetailTimeout = -100

  self.inventory = ItemStorage:new { size = 2560 }
    -- Remember to update this along self.portAssemblerTier!!!
  function self.inventory.onChanged(id, _, _)
    self.showStacks[id] = timer.getTime() + 3

    local previousRecipeCount = #self.recipes
    self:updateRecipes()
    if previousRecipeCount == 0 and #self.recipes > 0 then
      self.selectedRecipe = 1
      self.recipeDetailTimeout = timer.getTime() + 3
    end
  end
  self.showStacks = {}
end

--- Returns whether the player is falling.
--- @return boolean
function Player:isFalling()
  return self.body.velocity.y > 0.01
end

--- Returns the animation state of the player.
--- @return '"idle"' | '"walk"' | '"fall"'
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

--- Returns whether the player can jump.
--- @return boolean
function Player:canJump()
  return self.body.collidingWith.top or self.coyoteTimer > 0
end

--- Returns the current selected portAssembler recipe, or nil if there aren't
--- enough materials to build anything.
--- @return table
function Player:recipe()
  if #self.recipes > 0 then
    return self.recipes[self.selectedRecipe]
  else
    return nil
  end
end

--- Ticks the player.
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

  --
  -- Recipe selection
  --

  -- Panels use scroll events; we don't want to switch recipes while
  -- the player's interacting with the UI.
  if self:canUseLaser() then
    if math.abs(input.deltaScroll.y) > 0.1 and #self.recipes > 0 then
      local d = -common.round(input.deltaScroll.y)
      self.selectedRecipe = self.selectedRecipe + d
      self.selectedRecipe = (self.selectedRecipe - 1) % #self.recipes + 1

      local recipe = self:recipe()
      self.showStacks = {}
      for _, stack in ipairs(recipe.ingredients) do
        self.showStacks[stack.id] = timer.getTime() + 3
      end
      self.recipeDetailTimeout = timer.getTime() + 3
    end
  end
end

--- Ticks the player before physics.
--- This is used to prevent the laser from teleporting weirdly when the player
--- passes across the world seam.
function Player:prePhysicsUpdate()
  --
  -- Laser
  --

  -- modes
  if self:canUseLaser() then
    if input:mouseJustPressed(mbLeft) then
      self.laserMode = "destroy"
      self.laserEnabled = true
    elseif input:mouseJustPressed(mbRight) then
      self.laserMode = "construct"
      self.laserEnabled = self:recipe() ~= nil
    end
  end
  if input:mouseJustReleased(mbLeft) or input:mouseJustReleased(mbRight) then
    self.laserEnabled = false
  end

  -- charging
  if self.laserEnabled then
    local coeff =
      (self.laserMaxCharge - self.laserCharge) / self.laserMaxCharge *
      laserChargeRate[self.laserMode]
    self.laserCharge = self.laserCharge + self.laserMaxCharge * coeff
  else
    self.laserCharge = self.laserCharge * 0.6
  end

  if self.laserEnabled then
    local target, laserPosition = self:laserTarget()

    -- destruction laser
    if self.laserMode == "destroy" then
      local block = self.world:breakBlock(target, self.laserCharge)
      if block ~= nil then
        self.laserCharge = self.laserCharge - block.hardness * 2
      end
    end

    -- construction laser
    local recipe = self:recipe()
    if recipe ~= nil and self.laserMode == "construct" then
      if self.laserCharge > self.laserMaxCharge - 0.5 then
        local result = recipe.result
        local item = result.item
        local success =
          ((result.block ~= nil or result.machine ~= nil) and
          self.world:placeTile(target, recipe))
            or
          (item ~= nil and
          (self.world:dropItem(laserPosition,
                               items.drop(item.id, item.amount)) or true))
        if success then
          recipes.consume(recipe, self.inventory)
          self.laserCharge = 0
        end
      end
    end
  end

  -- sanitize the charge value
  self.laserCharge = math.max(self.laserCharge, 0)
end

--- Handles collision with another body.
--- @param body World.Body
function Player:collisionWithBody(body)
  if not Object.of(body.owner, Entity) then return end

  local entity = body.owner
  if entity:of(Item) then
    entity:take(self:takeItem(entity.stack))
  end
end

--- Attempts to take items from an item stack into the player's inventory,
--- according to the rules in ItemStorage:take.
--- Returns the actual amount of items taken.
---
--- @param idOrStack number | table
--- @param amount number | nil
--- @return number
function Player:takeItem(idOrStack, amount)
  return self.inventory:put(idOrStack, amount)
end

--- Updates the list of available portAssembler recipes.
function Player:updateRecipes()
  self.recipes = recipes.filter(self.inventory, unpack(self.recipeTargets))
  if self.selectedRecipe > #self.recipes then
    self.selectedRecipe = #self.recipes
  end
end

--- Interpolates the position of the player.
--- @return Vec
function Player:interpolatePosition(alpha)
  return self.body:interpolatePosition(alpha)
end

--- Returns the unbounded position of the mouse.
--- @return Vec
function Player:mousePosition()
  return self._camera:toWorldSpace(input.mouse)
end

--- Returns whether the player can use the laser.
--- This is false when the mouse cursor is over any UI elements.
--- @return boolean
function Player:canUseLaser()
  return not game.ui:mouseOverPanel()
end

--- Returns the position the player's pointing at with the laser.
--- @return Vec
function Player:laserPosition()
  -- This clamps the laser position to the maximum range.
  local center = self.body:center()
  local direction, len = (self:mousePosition() - center):normalized()
  len = math.min(len, self.laserRange)
  return center + direction * len
end

--- Returns the block the laser is targeting.
--- @return Vec
local unboundedTarget = true -- constant used as an argument to laserTarget
function Player:laserTarget(unbounded)
  local position
  if unbounded then
    position = self:mousePosition()
  else
    position = self:laserPosition()
  end
  return (position / Chunk.size):floor(), position
end

--- The colors of the laser core and glows.
local laserColors = {
  -- Glow colors
  none      = { rgba(0, 0, 0) },
  destroy   = { rgba(235, 19, 74) },
  construct = { rgba(0, 234, 255) },
  -- Core color
  core      = { rgba(255, 255, 255) },
}

--- Draws a laser.
--- @param from Vec
--- @param to Vec
--- @param thickness number
--- @param color table
local function drawLaser(from, to, thickness, color)
  graphics.setLineWidth(thickness)
  graphics.setColor(color)
  graphics.line(from.x, from.y, to.x, to.y)
  graphics.circle("fill", from.x, from.y, thickness / 2)
  graphics.circle("fill", to.x, to.y, thickness)
  graphics.setColor(white)
end

--- Renders the player.
--- @param alpha number
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
  local ts = Chunk.tileSize
  local laserTarget = (self:laserTarget()) * ts
  local unbLaserTarget = (self:laserTarget(unboundedTarget)) * ts
  if self:canUseLaser() or self.laserEnabled then
    if self.world:kind(self:laserTarget()) == "machine" then
      graphics.setLineWidth(2 / self._camera.scale)
      ggraphics.stippledRectangle(laserTarget.x, laserTarget.y, ts, ts, 1.5)
    else
      graphics.rectangle("line", laserTarget.x, laserTarget.y, ts, ts)
      graphics.setLineWidth(1 / self._camera.scale)
      graphics.rectangle("line", unbLaserTarget.x, unbLaserTarget.y, ts, ts)
    end
  end
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

--- Updates and returns the player's camera.
--- @param alpha number
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

--- Draws the player's inventory usage HUD.
--- @param self Player
local function inventoryHUD(self)
  local sx, sy = 16, 16

  local ix, iy = sx, sy + 20
  local y = 0
  local shownItems = false
  for id, time in pairs(self.showStacks) do
    if timer.getTime() < time then
      local amount = self.inventory:get(id)
      local quad = game.items[id].quad
      graphics.draw(game.itemAtlas.image, quad, ix, iy + y, 0, 3)

      local qty = quantity(amount)
      graphics.print(qty, ix + 32, iy + y)

      shownItems = true
      y = y + 32
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

--- Translates a recipe's result.
--- @param recipe table
local function trRecipe(recipe)
  local result = recipe.result
  if result.block ~= nil then
    return tr("block/"..Registry.key(game.blockIDs, result.block))
  elseif result.item ~= nil then
    return tr("item/"..Registry.key(game.itemIDs, result.item.id))
  elseif result.machine ~= nil then
    return tr("machine/"..result.machine.__name)
  end
  return recipe.name
end

--- Draws a recipe result at the given position.
--- @param x number
--- @param y number
--- @param recipe table
--- @param scale number
local function drawRecipe(x, y, recipe, scale)
  -- sprite
  local result = recipe.result
  local atlas, quad
  if result.block ~= nil then
    atlas = game.terrainAtlas
    quad = game.blocks[result.block].variantQuads[1][1]
  elseif result.item ~= nil then
    atlas = game.itemAtlas
    quad = game.items[result.item.id].quad
  elseif result.machine ~= nil then
    local sprite = game.machines[result.machine.__name].sprites[1]
    graphics.draw(sprite, x, y, 0, scale)
    return
  end
  graphics.draw(atlas.image, quad, x, y, 0, scale)

  -- item: amount
  if result.item ~= nil then
    graphics.printf(quantity(result.item.amount), x - 8, y + 24 - 10,
                    24, "center")
  end
end

--- Draws the player's portAssembler selection HUD.
--- @param self Player
local function portAssemblerHUD(self)
  local w, h = graphics.getDimensions()
  local x = w - 40

  local by = h / 2 - (self.selectedRecipe - 1) * 40 - 12
  for i, recipe in ipairs(self.recipes) do
    if self.selectedRecipe == i then
      local width, height = 24, 24
      graphics.rectangle("line", x - 8.5, by - 8.5, width + 16, height + 16)
    end
    drawRecipe(x, by, recipe, 3)
    by = by + 40
  end

  local recipe = self:recipe()
  if recipe ~= nil and timer.getTime() < self.recipeDetailTimeout then
    local ix = x - 80
    local iy = h / 2
    graphics.printf(trRecipe(recipe), game.fonts.bold, x - 32 - 256, iy - 32,
                    256, "right")
    for _, stack in ipairs(recipe.ingredients) do
      local quad = game.items[stack.id].quad
      graphics.draw(game.itemAtlas.image, quad, ix, iy, 0, 3)
      graphics.print(quantity(stack.amount), ix + 32, iy)
      iy = iy + 32
    end
  end
end

--- Draws the player's HUD.
function Player:ui()
  inventoryHUD(self)
  portAssemblerHUD(self)
end

--- The amount of columns of inventory items to be shown.
local inventoryColumns = 6

--- Draws the player's left panel.
--- @param ui Ui
function Player:leftPanel(ui)
  -- inventory panel
  if ui:beginAccordionPanel(ui:width(), 320, "Inventory",
                            {expandedByDefault = true})
  then
    -- occupied space progress bar
    local occupied = self.inventory:occupied()
    local size = self.inventory.size
    local occupiedRatio = occupied / size
    local freeLabel
    if self.inventory:free() > 0 then
      local freePercent = 100 - occupiedRatio * 100
      freeLabel = tr("player/inventory/spaceFree"):format(freePercent)
    else
      freeLabel = tr "player/inventory/full"
    end
    ui:progress(occupiedRatio, {
      color = ui.mapProgressColor(occupiedRatio, 0.7, 0.9),
      style = "tall",
      label = ("%.0f / %.0f (%s)"):format(occupied / 10, size / 10, freeLabel),
    })
    ui:space(4)
    -- item storage view
    ui:itemStorageView(self.inventory, {
      columns = inventoryColumns,
      height = ui:remHeight(),
      emptyText = tr "player/inventory/empty",
    })
  end ui:endPanel()
end

--- Draws the player's right panel.
--- @param ui Ui
function Player:rightPanel(ui)
  portAssemblerHUD(self)
end

return Player
