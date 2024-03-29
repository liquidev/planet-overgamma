-- The game state.

local graphics = love.graphics

local rgba = love.math.colorFromBytes

local common = require "common"
local Camera = require "camera"
local game = require "game"
local Player = require "entities.player"
local State = require "state"
local World = require "world"

local input = game.input
local ui = game.ui

local white = common.white

---

--- @class GameState: State
local GameState = State:inherit()

--- Initializes the game state.
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
      print((" - stage took %.1f ms"):format(a * 1000))
    elseif kind == "error" then
      error("in world generator: "..a)
    end
  end
  print("world is ready")

  self.player = self.world:spawn(Player:new(self.world))
  self.player.body.position.y = -128

  self.camera = Camera:new()

  self.debugMode = os.getenv("PO_DEBUG") == "1"
  if self.debugMode then
    -- I guess this will stay until I add some sort of creative mode.
    -- Maybe _this_ will be the creative mode? 🤔
    if os.getenv("GIVE_ME_ALL_THE_GOOD_STUFF") == "YES" then
      self.player.inventory.size = math.huge
      for id, _ in pairs(game.items) do
        self.player.inventory:put(id, 5120)
      end
    end
  end
end

--- Updates the game.
function GameState:update()
  self.world:update()

  if input:keyJustPressed('/') then
    self.debugMode = not self.debugMode
  end
end

--- Renders the game.
--- @param alpha number  The interpolation coefficient.
function GameState:draw(alpha)
  self.world:draw(alpha, self.player:camera(alpha))

  ui:begin("freeform")
  ui:pad(16)
  ui:push("vertical", 232, ui:height()) do
    self.player:leftPanel(ui)
  end ui:pop()
  self.player:rightPanel(ui)

  if self.debugMode then
    local w, _ = graphics.getDimensions()
    local position = self.player.body.position
    local x, y = math.floor(position.x), math.floor(position.y)
    local lx, ly = self.player:laserPosition()
      :div(World.Chunk.size)
      :floor()
      :xy()
    local text =
      "Unit\nX: "..x.."\nY: "..y..
      "\n\nBlock\nX: "..math.floor(x / World.Chunk.size)..
      "\nY: "..math.floor(y / World.Chunk.size)..
      "\n\nTarget Tile:\nX: "..lx.."\nY: "..ly
    graphics.printf(text, w - 256 - 8, 8, 256, "right")
  end
end

return GameState
