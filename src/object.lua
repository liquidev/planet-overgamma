-- Simple object-oriented framework.
-- Stolen from rxi's lite text editor.
-- https://github.com/rxi/lite

local Object = {}
Object.__index = Object

-- Initialization hook.
-- If not overridden, this errors out with the message "this object cannot be
-- initialized".
function Object:init()
  error("this object cannot be initialized")
end

-- Creates an object.
-- This delegates all passed parameters to the `init` function and returns
-- the initialized object.
function Object:new(...)
  local o = setmetatable({}, self)
  o:init(...)
  return o
end

-- Creates a new object type that inherits from this object type.
function Object:inherit()
  local child = {}
  child.__index = child
  child.super = self
  setmetatable(child, self)
  return child
end

-- Returns whether this object inherits from the object type T.
function Object:of(T)
  local mt = getmetatable(self)
  while mt ~= nil do
    if mt == T then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end


return Object
