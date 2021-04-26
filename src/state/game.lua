-- The game state.

local Camera = require "camera"
local game = require "game"
local State = require "state"
local World = require "world"
local Vec = require "vec"

local input = game.input

---

local GameState = State:inherit()

-- Initializes the game state.
function GameState:init()
  self.super.init(self)

  self.world = World:new(32)
  -- temporary init code until i implement worldgen
  local plants = game.blockIDs["core:plants"]
  for y = 0, 32 do
    for x = 0, 32 do
      self.world:block(Vec(x, y), plants)
    end
  end
  print("world is ready")

  self.camera = Camera:new()
end

-- Updates the game.
function GameState:update()
  if input:keyDown('d') then
    self.camera:applyPan(Vec(1, 0))
  end
  if input:keyDown('a') then
    self.camera:applyPan(Vec(-1, 0))
  end
  if input:keyDown('s') then
    self.camera:applyPan(Vec(0, 1))
  end
  if input:keyDown('w') then
    self.camera:applyPan(Vec(0, -1))
  end
end

-- Renders the game.
function GameState:draw(alpha)
  self.camera:transform(World.draw, nil, self.world)
end

return GameState
