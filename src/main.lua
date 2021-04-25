----
-- Planet Overgamma (the new)
---
-- Welcome! Welcome to City 17.
-- This file is where the main loop of the game happens.
-- Since I don't like how LÖVE2D's game loop works, I made my own.

local event = love.event
local graphics = love.graphics
local timer = love.timer

local game = require "game" -- initialize game resources before anything else
local Mod = require "mod"

--
-- Variables
--

local state = require("state.game"):new()

--
-- Game loop
--

local tickRate = 60
local timePerTick = 1 / tickRate

function love.run()
  -- Planet Overgamma uses a fixed timestep game loop, running at 60 tps for
  -- a smooth experience™.
  -- Basically this means that every second, a fixed number of ticks happens.
  -- This lets the game run at a constant speed, regardless of what machine it's
  -- running on.
  -- To make movement less stuttery, an extra `alpha` is passed to the rendering
  -- code. This is a coefficient of how much between two frames the current
  -- frame is, and can be used together with linear interpolation to achieve
  -- silky smooth movement regardless of your refresh rate.

  -- initialize

  math.randomseed(os.time())

  local mods, errors = Mod.loadMods({})
  if #errors > 0 then
    print("errors occured while loading mods:")
    print(errors)
  end

  timer.step()

  local previous = timer.getTime()
  local lag = 0

  return function ()
    local now = timer.getTime()
    local delta = now - previous
    previous = now
    lag = lag + delta

    -- events
    event.pump()
    for kind, a, b, c, d, e, f in event.poll() do
      if kind == "quit" then
        return a or 0
      else
        game.input:processEvent { kind = kind, a, b, c, d, e, f }
      end
    end

    -- updates
    while lag >= timePerTick do
      state:update()
      lag = lag - timePerTick
      -- The frame is finished after a single tick, because we don't want
      -- repeated momentary inputs.
      game.input:finishFrame()
    end

    -- rendering
    local alpha = lag / timePerTick
    graphics.origin()
    graphics.clear(0, 0, 0, 0, 0)
    state:draw(alpha)
    graphics.present()

    -- state switching
    if state._nextState ~= nil then
      state = state._nextState
    end
  end
end

