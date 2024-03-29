-- Mod definition, loading, etc.
--
-- Every mod must be located under the data/mods directory next to the game,
-- and have an init.lua file inside of it.
-- This init.lua must construct and return a Mod object.

local fs = love.filesystem

local common = require "common"
local game = require "game"
local i18n = require "i18n"
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

-- Loads an image if the argument is a string containing a filename, otherwise
-- returns the argument.
local function loadImage(mod, image)
  if type(image) == "string" then
    local imagePath = mod.path..'/'..image
    image = love.image.newImageData(imagePath)
  end
  return image
end

-- Adds a new block from an image (filename or ImageData).
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
-- into the block before adding it into the block registry. The function will
-- return the block ID and final block upon calling.
function Mod:addBlock(key, image, kind)
  image = loadImage(self, image)
  if kind ~= "block" and kind ~= "4x4" then
    if image:getWidth() * image:getHeight() < 32 * 32 then
      kind = "block"
    else
      kind = "4x4"
    end
  end

  return function (extra)
    local variantRects = {}
    if kind == "4x4" then
      tiles.pack4x4(variantRects, game.terrainAtlas, image)
    else
      tiles.packBlock(variantRects, game.terrainAtlas, image)
    end

    local block = tables.merge({
      variantRects = variantRects,
      isSolid = true,
    }, extra)
    local id = game.addBlock(self:namespaced(key), block)
    block.tilesWith = { [id] = true }

    return id, block
  end
end

-- Adds a new ore from an image (filename or ImageData). The image must be a
-- horizontal strip of sprites, representing different ore saturation levels.
-- Returns a function that accepts a table of properties that should get merged
-- into the ore before adding it into the ore registry. The function will return
-- the ore ID and final ore table upon calling.
function Mod:addOre(key, image)
  image = loadImage(self, image)

  return function (extra)
    local rects = tiles.packOre({}, game.terrainAtlas, image)
    local ore = tables.merge({
      rects = rects,
      saturatedAt = #rects * 10,
    }, extra)
    local id = game.addOre(self:namespaced(key), ore)
    return id, ore
  end
end

-- Adds a new item from an image (filename or ImageData) and returns its ID and
-- item data table.
function Mod:addItem(key, image)
  image = loadImage(self, image)

  local item = {
    rect = game.itemAtlas:pack(image)
  }
  return game.addItem(self:namespaced(key), item)
end

-- Adds a new machine into the game. M is the machine object, which must
-- inherit from Machine. The image (filename or ImageData) must be a horizontal
-- strip of sprites.
-- M's __name field is modified to be prefixed with the mod's namespace.
function Mod:addMachine(M, image)
  image = loadImage(self, image)

  M.__name = self:namespaced(M.__name)
  local machine = {
    Object = M,
    sprites = tiles.extractMachineSprites({}, image)
  }
  return game.addMachine(machine)
end

-- Adds a new recipe for the given target.
--
-- target can be any arbitrary string used to uniquely identify the usage
-- of the recipe, but there are a few well-defined targets the core of
-- the game uses:
--  · "portAssembler.<tier>" - recipes for the player's portAssembler, where
--    <tier> is an integer specifying which portAssembler tier the recipe is
--    usable with.
--
-- recipe is a table with the following fields:
--  · name: string | nil - a name for debugging purposes,
--    namespaced automatically. defaults to "unnamed"
--  · ingredients: {{ items.stack }} - the items used to construct the result
--  · result: any - target-specific result
function Mod:addRecipe(target, recipe)
  recipe.name = self:namespaced(recipe.name or "unnamed")
  return game.addRecipe(target, recipe)
end

-- Adds multiple recipes for multiple targets.
-- The recipes table must have the following structure:
-- {
--   target = {{…}, {…}, …},
--   …
-- }
function Mod:addRecipes(recipes)
  for target, targetRecipes in pairs(recipes) do
    for _, recipe in ipairs(targetRecipes) do
      self:addRecipe(target, recipe)
    end
  end
end

-- Adds a world generator.
--
-- The generator's name is modified so that it's prefixed with the mod's
-- namespace.
function Mod:addWorldGenerator(generator)
  generator.name = self:namespaced(generator.name)
  game.addWorldGenerator(generator)
end

-- Adds a translations module from the mod.
-- module defaults to "tr".
function Mod:addTranslations(module)
  module = module or "tr"
  return i18n.addModule("mods."..self.namespace..'.'..module)
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
--
-- Note that each search path must be the _parent_ directory of a `mods`
-- directory, for require to work properly.
Mod.searchPaths = {"data"}

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
    searchPath = searchPath.."/mods"
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

