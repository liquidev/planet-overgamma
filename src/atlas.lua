-- Texture atlas for packing sprites into a bigger one, for better rendering
-- performance.

local graphics = love.graphics
local image = love.image

local Object = require "object"
local RectPacker = require "rect-packer"
local Registry = require "registry"
local Vec = require "vec"

---

local Atlas = Object:inherit()

-- Initializes a new, empty texture atlas with the given size.
function Atlas:init(size)
  local imageData = image.newImageData(size.x, size.y)
  self.image = graphics.newImage(imageData)
  self.packer = RectPacker:new(size)
  self.registry = Registry:new()
  self.rects = {}
end

-- Packs a piece of ImageData and returns its ID and rectangle, or
-- returns nil if there is no space left on the image.
function Atlas:pack(key, imageData)
  local width, height = imageData:getDimensions()
  local rect = self.packer:pack(Vec(width, height))
  if rect == nil then
    return nil
  end

  if Registry.hasKey(self.registry, key) then
    error("duplicate texture name '"..key.."' in atlas")
  end
  local id = self.registry[key]
  self.image:replacePixels(imageData, 0, 1, rect.x, rect.y)
  self.rects[id] = rect
  return id, rect
end

-- Returns the rectangle for the texture with the given ID or key,
-- or nil if there is no rectangle with the given ID or key.
-- `id` may be a string or a number.
function Atlas:get(id)
  if type(id) == "string" then
    if Registry.hasKey(self.registry, id) then
      id = self.registry[id]
    else
      return nil
    end
  end
  return self.rects[id]
end

return Atlas
