-- Texture atlas for packing sprites into a bigger one, for better rendering
-- performance.

local graphics = love.graphics
local image = love.image

local Object = require "object"
local RectPacker = require "rect-packer"
local Vec = require "vec"

---

local Atlas = Object:inherit()

-- Initializes a new, empty texture atlas with the given size.
function Atlas:init(size)
  local imageData = image.newImageData(size.x, size.y)
  self.image = graphics.newImage(imageData)
  -- for some reason graphics.setDefaultFilter doesn't affect sprite batches
  self.image:setFilter("nearest", "nearest")
  self.packer = RectPacker:new(size)
end

-- Packs a piece of ImageData and returns its rectangle, or
-- returns nil if there is no space left on the image.
function Atlas:pack(imageData)
  local width, height = imageData:getDimensions()
  local rect = self.packer:pack(Vec(width, height))
  if rect == nil then
    return nil
  end
  self.image:replacePixels(imageData, 0, 1, rect.x, rect.y)
  return rect
end

return Atlas
