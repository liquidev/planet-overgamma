-- "Fibers" as wrappers for coroutines.
--
-- This is largely inspired by lite's threads, as in, it's basically a wrapper
-- for juggling coroutines around. It's named "fibers" because "thread" is
-- already taken by love.thread.
--
-- Since there could be many different groups of fibers all scheduled to run
-- at different points in time (eg. some may run during fixed timestep updates,
-- some may run during rendering), starting a new fiber is done through a
-- scheduler that executes fibers at some well-defined point in time.

local timer = love.timer

local Object = require "object"

---

local Scheduler = Object:inherit()

-- Initializes a new scheduler with the given name.
function Scheduler:init(name)
  self.name = name
  self.fibers = {}
end

-- Adds a new fiber to the scheduler and returns a handle to it.
-- The fiber can be later aborted through this handle, if necessary.
--
-- fiber is a function that is passed to coroutine.create. This function can
-- use coroutine.yield(time), where time is the time for which the fiber should
-- sleep before being ticked again.
-- Note that this timing is not precise. The fiber may sleep for longer, but not
-- shorter than the specified time. The exact time depends on how frequently
-- Scheduler:tick is called.
function Scheduler:start(name, fiber)
  local handle = { name = name, coro = coroutine.create(fiber), wakeAt = 0 }
  table.insert(self.fibers, handle)
  return handle
end

-- Aborts a fiber with the given handle.
-- This forcibly stops the fiber, and it will not be ticked upon the next
-- call to Scheduler:tick().
-- Does nothing if the fiber handle is not part of the scheduler (comes from a
-- different scheduler, or has already been aborted).
function Scheduler:abort(handle)
  for i, fiber in ipairs(self.fibers) do
    if fiber == handle then
      self.fibers[i] = nil
      return
    end
  end
end

-- Ticks the scheduler: executes every active fiber, removes inactive fibers,
-- and ignores sleeping fibers.
--
-- Extra arguments passed to this function are passed to all running fibers.
function Scheduler:tick(...)
  local time = timer.getTime()
  local i = 1
  while i <= #self.fibers do
    local fiber = self.fibers[i]
    local coro = fiber.coro
    if time >= fiber.wakeAt then
      local ok, result = coroutine.resume(coro, ...)
      if not ok then
        error("scheduler for '"..self.name.."': "..
              "ticking '"..fiber.name.."' failed with an error\n"..result)
      else
        if coroutine.status(coro) == "dead" then
          self.fibers[i] = self.fibers[#self.fibers]
          self.fibers[#self.fibers] = nil
          i = i - 1
        elseif result ~= nil and result > 0 then
          fiber.wakeAt = time + result
        end
      end
    end
    i = i + 1
  end
end

return Scheduler
