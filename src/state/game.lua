-- The game state.

local Camera = require "camera"
local game = require "game"
local Player = require "player"
local State = require "state"
local World = require "world"
local Vec = require "vec"

local input = game.input

---

local GameState = State:inherit()

-- Initializes the game state.
function GameState:init()
  self.super.init(self)

  self.world = World:new(32, Vec(0, 0.5))
  -- temporary init code until i implement worldgen
  local plants = game.blockIDs["core:plants"]
  for y = 0, 32 do
    for x = 0, 32 do
      if math.random() > 0.5 then
        self.world:block(Vec(x, y), plants)
      end
    end
  end
  print("world is ready")

  self.player = self.world:spawn(Player:new(self.world))

  self.camera = Camera:new()
end

-- Updates the game.
function GameState:update()
  self.world:update()
end

-- Renders the game.
function GameState:draw(alpha)
  self.player:camera(alpha):transform(World.draw, nil, self.world, alpha)
end

return GameState
