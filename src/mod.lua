-- Mod definition, loading, etc.
--
-- Every mod must be located under the data/mods directory next to the game,
-- and have an init.lua file inside of it.
-- This init.lua must construct and return a Mod object.

local fs = love.filesystem

local common = require "common"
local game = require "game"
local Object = require "object"
local tables = require "tables"
local tiles = require "world.tiles"

---

local Mod = Object:inherit()

-- Initializes a new mod with the provided root path and namespace.
function Mod:init(path, namespace)
  self.path = path
  self.namespace = namespace
end

-- Initializes a mod's metadata. This must be called by the mod's main file
-- upon loading.
-- The metadata table must follow this structure:
-- {
--   -- required fields:
--   name: string, -- pretty name
--   version: string,
--   author: string,
--   description: string,
-- }
function Mod:metadata(metadata)
  assert(type(metadata.name) == "string", "mod name must be a string")
  assert(type(metadata.version) == "string", "mod version must be a string")
  assert(type(metadata.author) == "string", "mod author must be a string")
  assert(type(metadata.description) == "string",
         "mod description must be a string")
  self.name = metadata.name
  self.version = metadata.version
  self.author = metadata.author
  self.description = metadata.description
end

-- Returns a namespaced name, with the namespace of the given mod.
-- This should be preferred instead of constructing namespaced names directly.
--
-- `namespace` may be a Mod or a string.
-- This function can be called using `:` on a Mod, if that's more convenient.
function Mod.namespaced(namespace, name)
  if type(namespace) ~= "string" then
    namespace = namespace.namespace
  end
  return string.format("%s:%s", namespace, name)
end

-- Loads a new block from an image (file or ImageData).
-- `kind` specifies the loading mode, and may be either "block" or "4x4".
-- If omitted, the mode will be guessed based on the image's size
-- ("block" if < 32x32, "4x4" otherwise). This comparison is done by computing
-- the surface area of the image and comparing it to the threshold
-- of 32×32 pixels, so eg. a 48×20 image classifies as a "block", but a
-- 48×24 image classifies as a "4x4".
--
-- "block" specifies that the image represents a single block that doesn't
-- connect to other blocks.
-- "4x4" specifies that the block connects to other blocks (it "auto-tiles"),
-- and the image is a 4x4 block tilemap.
--
-- 4x4 block tilemaps are made up of 4x4 individual tile textures, arranged
-- like this:
--[[
  +-- --- --+ +-+
  |         | | |
  |         | | |

  |         | | |
  |         | | |
  |         | | |

  |         | | |
  |         | | |
  +-- --- --+ +-+

  +-- --- --+ +-+
  |         | | |
  +-- --- --+ +-+
]]
-- The tiles have to be tightly packed into a texture whose size is divisible
-- by 4, preferably 32x32 (8x8 tiles), to fit the rest of the game.
--
-- Returns a function that accepts a table of properties that should get merged
-- into the block before adding it into the tile registry. The function will
-- return the block ID and final block upon calling.
function Mod:addBlock(key, image, kind)
  if type(image) == "string" then
    local imagePath = self.path..'/'..image
    image = love.image.newImageData(imagePath)
  end
  if kind ~= "block" and kind ~= "4x4" then
    if image:getWidth() * image:getHeight() < 32 * 32 then
      kind = "block"
    else
      kind = "4x4"
    end
  end

  local rects = {}
  if kind == "4x4" then
    tiles.packBlock(rects, game.blockAtlas, image)
  else
    local rect = game.blockAtlas:pack(image)
    tables.fill(rects, 16, rect)
  end

  return function (extra)
    local block = { rects = rects }
    tables.merge(block, extra)
    local id = game.addBlock(self:namespaced(key), block)
    block.tilesWith = { [id] = true }
    return id, block
  end
end


--
-- Mod loader
--

-- Loads the mod at the given path.
-- The provided path must be a directory. Otherwise an error is raised.
function Mod.load(path, namespace)
  local info = fs.getInfo(path)
  assert(info ~= nil, "the provided mod directory does not exist: "..path)
  assert(info.type == "directory",
         "the provided path is not a directory: "..path)
  local ok, err = fs.load(path.."/init.lua")
  if ok ~= nil then
    local mod = Mod:new(path, namespace)
    ok(mod)
    if mod.name == nil then
      error("mod at "..path.." is not a valid mod\n" ..
            " - mods must specify metadata through Mod:metadata {}")
    end
    print("loaded mod: "..mod.name..' '..mod.version.." by "..mod.author)
    return mod
  else
    error("could not load mod "..path..": "..err)
  end
end

-- Contains all the available search paths for mods.
-- This should never be modified, as these search paths are scanned only
-- once by the mod loader.
Mod.searchPaths = {"data/mods"}

-- Appends the appropriate require paths to the global require search path.
-- This only has an effect once.
local requirePathsPresent = false
function Mod.addRequirePaths()
  if not requirePathsPresent then
    print("adding mod require paths")
    local path = fs.getRequirePath()
    for _, searchPath in ipairs(Mod.searchPaths) do
      path = path..';'..searchPath.."/?.lua"
      path = path..';'..searchPath.."/?/init.lua"
    end
    fs.setRequirePath(path)
    requirePathsPresent = true
  end
end

-- Loads mods into the provided table from standard search paths.
-- Returns the table with all the mods loaded in, along with a string
-- containing any errors that occured while loading mods.
function Mod.loadMods(modTable)
  Mod.addRequirePaths()

  local errors = {}
  for _, searchPath in ipairs(Mod.searchPaths) do
    print("loading mods from "..searchPath)
    for _, namespace in ipairs(fs.getDirectoryItems(searchPath)) do
      local path = searchPath..'/'..namespace
      local ok, result = common.try(Mod.load, path, namespace)
      if ok then
        table.insert(modTable, result)
      else
        table.insert(errors, "in "..path..": "..result)
      end
    end
  end

  return modTable, table.concat(errors, '\n')
end

return Mod

