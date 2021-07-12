-- ----
-- -- Planet Overgamma (the new)
-- ---
-- -- Welcome! Welcome to City 17.
-- -- This file is where the main loop of the game happens.
-- -- Since I don't like how LÖVE2D's game loop works, I made my own.

-- local event = love.event
-- local graphics = love.graphics
-- local timer = love.timer

-- -- Initialize game resources before everything else.
-- local game = require "game"
-- require "game.functions"
-- require "game.load"

-- -- Just in case this isn't explicitly required anywhere else.
-- require "ui"

-- local tween = require "tween"

-- --
-- -- Variables
-- --

-- local state

-- --
-- -- Game loop
-- --

-- local tickRate = 60
-- local timePerTick = 1 / tickRate

-- local profiler = require "ext.profiler"
-- local profilerEnabled = os.getenv("PO_PROFILER") == "1"
-- if profilerEnabled then
--   print(":: profiling is enabled")
-- end
-- profiler.attachPrintFunction(print)

-- function love.run()
--   -- Planet Overgamma uses a fixed timestep game loop, running at 60 tps for
--   -- a smooth experience™.
--   -- Basically this means that every second, a fixed number of ticks happens.
--   -- This lets the game run at a constant speed, regardless of what machine it's
--   -- running on.
--   -- To make movement less stuttery, an extra `alpha` is passed to the rendering
--   -- code. This is a coefficient of how much between two frames the current
--   -- frame is, and can be used together with linear interpolation to achieve
--   -- silky smooth movement regardless of your refresh rate.

--   os.setlocale("C")

--   math.randomseed(os.time())
--   graphics.setDefaultFilter("nearest", "nearest")

--   game.load()
--   state = require("state.game"):new()

--   timer.step()

--   local previous = timer.getTime()
--   local lag = 0

--   if profilerEnabled then
--     profiler.start()
--   end

--   return function ()
--     local now = timer.getTime()
--     local delta = now - previous
--     previous = now
--     lag = lag + delta
--     lag = math.min(lag, timePerTick * 3)

--     -- events
--     event.pump()
--     for kind, a, b, c, d, e, f in event.poll() do
--       if kind == "quit" then
--         if profilerEnabled then
--           profiler.stop()
--           profiler.report("profile.log")
--         end
--         return a or 0
--       else
--         local ev = { kind = kind, a, b, c, d, e, f }
--         game.ui.input:processEvent(ev)
--         game.input:processEvent(ev)
--       end
--     end

--     -- updates
--     while lag >= timePerTick do
--       state:update()
--       lag = lag - timePerTick
--       -- The frame is finished after a single tick, because we don't want
--       -- repeated momentary inputs.
--       game.input:finishFrame()
--     end

--     -- rendering
--     local alpha = lag / timePerTick
--     graphics.origin()
--     graphics.clear(0, 0, 0, 1.0, 0)
--     state:draw(alpha)
--     graphics.present()
--     -- The UI's input is reset every frame, because the UI is redrawn
--     -- every frame, and each UI redraw also handles input.
--     game.ui.input:finishFrame()
--     tween.update()

--     -- state switching
--     if state._nextState ~= nil then
--       state = state._nextState
--     end
--   end
-- end

