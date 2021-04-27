-- Player controls, world interaction, etc.

local graphics = love.graphics

local Camera = require "camera"
local Entity = require "world.entity"
local game = require "game"

---

local Player = Entity:inherit()

-- Initializes the player with the given world.
function Player:init(world)
  self.camera = Camera:new()
  self.world = world
  -- For now this is hardcoded to blue, later I might add player color selection
  -- but now is not the time.
  self.sprites = game.playerSprites.blue
end

-- Returns the animation state of the player ("idle" | "walk" | "fall")
function Player:animationState()
  return "idle"
end

-- Ticks the player.
function Player:update()

end

-- Renders the player.
function Player:draw(alpha)
  graphics.draw(self.sprites[self:animationState()], 0, 0)
end

return Player
