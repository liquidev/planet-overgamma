-- A simple, global tweening engine.

local timer = love.timer

local common = require "common"
local easings = require "easings"

local clamp = common.clamp
local lerp = common.lerp

---

local tween = {
  -- Currently running tweeners.
  active = {},
}

--- Returns get/set functions for a table field.
---
--- @param table table    The table to get the field from.
--- @param field string   The name of the field in the table.
--- @return function get  A getter for the chosen field.
--- @return function set  A setter for the chosen field.
function tween.field(table, field)
  return
    -- get
    function ()
      return table[field]
    end,
    -- set
    function (v)
      table[field] = v
    end
end

--- Lerp function that works on number and table types.
---
--- Only a's type is checked, and b is assumed to be the same type.
--- If the type is a number, `common.lerp(a, b, t)` is used.
--- Otherwise, `a:lerp(b, t)` is used.
---
--- @param a number | table
--- @param b number | table
--- @param t number
function tween.lerp(a, b, t)
  if type(a) == "number" then
    return lerp(a, b, t)
  elseif type(a) == "table" then
    return a:lerp(b, t)
  else
    error(type(a).." values cannot be interpolated")
  end
end

--- Starts a tweener for the given destination value, duration, easing, and
--- pair of get/set functions, and returns the tweener.
---
--- `get` and `set` are usually populated by functions like `tween.field`, hence
--- why they're the last parameters.
---
--- If `easing` is a string, the easing function is looked up from the `easings`
--- module. Note that parametric easings are not available using this shorthand.
---
--- @param to number | table         The destination value.
--- @param duration number           The duration of the tween.
--- @param easing function | string  The easing function to use.
--- @param get function              A getter function for the tweened value.
--- @param set function              A setter function for the tweened value.
--- @return table tweener  The now active tweener.
function tween.start(to, duration, easing, get, set)
  if type(easing) == "string" then
    easing = easings[easing]
  end
  local from = get()
  local start = timer.getTime()
  -- The tweener is a function that performs the chosen easing and updates the
  -- tweened value. The tweener returns `true` when it's finished, to signal
  -- that it may be removed from the list of active tweeners.
  local tweener = {
    update = function (time)
      local t = clamp((time - start) / duration, 0, 1)
      local y = easing(t)
      set(lerp(from, to, y))
      return t >= 1
    end,
    start = start,
    duration = duration,
  }
  table.insert(tween.active, tweener)
  return tweener
end

--- Stops the provided tweener.
---
--- `tweener` may be nil, in which case nothing is done.
--- `tweener` may also be an already stopped tweener, in which case nothing is
--- done, too.
---
--- @param tweener table  The tweener to stop.
function tween.stop(tweener)
  if tweener ~= nil then
    for i, t in ipairs(tween.active) do
      if t == tweener then
        tween.active[i] = tween.active[#tween.active]
        tween.active[#tween.active] = nil
        return
      end
    end
  end
end

--- Finishes performing the given tweener.
function tween.finish(tweener)
  if tweener ~= nil then
    tweener.update(tweener.start + tweener.duration)
    tween.stop(tweener)
  end
end

--- Updates all active tweeners, and removes tweeners that have already
--- finished tweening.
function tween.update()
  local time = timer.getTime()
  local i = 1
  while i <= #tween.active do
    local tweener = tween.active[i]
    if tweener.update(time) then
      tween.active[i] = tween.active[#tween.active]
      tween.active[#tween.active] = nil
    else
      i = i + 1
    end
  end
end

-- tween exports all functions available in easings
for k, v in pairs(easings) do
  tween[k] = v
end

return tween

