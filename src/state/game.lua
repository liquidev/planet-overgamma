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

  local gen = game.worldGenerators["core:canon"]
  print("generating world…")
  for kind, a, b in gen:generate{} do
    if kind == "stage" then
      print("stage "..a..": "..b)
    elseif kind == "done" then
      self.world = a
    elseif kind == "time" then
      print(" - "..a * 1000 .. " ms")
    elseif kind == "error" then
      error("in world generator: "..a)
    end
  end
  print("world is ready")

  self.player = self.world:spawn(Player:new(self.world))
  self.player.body.position.y = -128
--   self.player.inventory:put(game.itemIDs["core:plantMatter"], 160)

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
