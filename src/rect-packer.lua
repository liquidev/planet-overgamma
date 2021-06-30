-- Wrapper over ext.binpack.

local Binpack = require "ext.binpack"

local Object = require "object"
local Rect = require "rect"

---

local RectPacker = Object:inherit()

-- Initializes a new rect packer with the given `size` (Vec).
function RectPacker:init(size)
  self.bp = Binpack(size.x, size.y)
end

-- Packs a new rectangle with the given size and returns the packed Rect, or nil
-- if there is no space left in the bin.
function RectPacker:pack(size)
  local rect = self.bp:insert(size.x, size.y)
  if rect ~= nil then
    return Rect:new(rect.x, rect.y, rect.w, rect.h)
  end
end

return RectPacker
