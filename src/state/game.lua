-- The game state.

local Camera = require "camera"
local game = require "game"
local Player = require "entities.player"
local State = require "state"
local World = require "world"
local Vec = require "vec"

---

local GameState = State:inherit()

-- Initializes the game state.
function GameState:init()
  self.super.init(self)

  self.world = World:new(32, Vec(0, 0.5))
  -- temporary init code until i implement worldgen
  local plants = game.blockIDs["core:plants"]
  local rock = game.blockIDs["core:rock"]
  for x = 0, 32 do
    local sy = -math.floor(math.sin(x * math.pi / 16) * 3)
    for y = sy, 16 do
      self.world:block(Vec(x, y), plants)
    end
    for y = 8 + sy, 48 do
      self.world:block(Vec(x, y), rock)
    end
  end
  print("world is ready")

  self.player = self.world:spawn(Player:new(self.world))
  self.player.body.position.y = -32
  self.player.inventory:put(game.itemIDs["core:plantMatter"], 160)

  self.camera = Camera:new()
end

-- Updates the game.
function GameState:update()
  self.world:update()
end

-- Renders the game.
function GameState:draw(alpha)
  self.world:draw(alpha, self.player:camera(alpha))
  self.player:ui()
end

return GameState
