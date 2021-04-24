-- The game state.

local game = require "game"
local State = require "state"

local input = game.input

---

local GameState = State:inherit()

-- Initializes the game state.
function GameState:init()
  self.super.init(self)
end

-- Updates the game.
function GameState:update()
  print(input.mouse, input.previousMouse, input.deltaMouse)
end

-- Renders the game.
function GameState:draw(alpha)

end

return GameState
