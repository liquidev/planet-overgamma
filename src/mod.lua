-- Mod definition, loading, etc.
--
-- Every mod must be located under the data/mods directory next to the game,
-- and have an init.lua file inside of it.
-- This init.lua must construct and return a Mod object.

local fs = love.filesystem

local common = require "common"
local Object = require "object"

---

local Mod = Object:inherit()

-- Initializes a new mod with the provided metadata.
-- The metadata must follow the following structure:
-- {
--   -- required fields:
--   name: string, -- pretty name
--   version: string,
--   author: string,
--   description: string,
-- }
function Mod:init(path, namespace)
  self.path = path
  self.namespace = namespace
end

-- Initializes a mod's metadata. This must be called by the mod's main file
-- upon loading.
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

-- Loads the mod at the given path.
-- The provided path must be a directory. Otherwise an error is raised.
function Mod.load(path, namespace)
  local info = fs.getInfo(path)
  assert(info ~= nil, "the provided mod directory does not exist: "..path)
  assert(info.type == "directory",
         "the provided path is not a directory: "..path)
  local ok, err = fs.load(path .. "/init.lua")
  if ok ~= nil then
    local mod = Mod:new(path, namespace)
    ok(mod)
    if mod.name == nil then
      error("mod at "..path.." is not a valid mod\n" ..
            " - valid mods must specify metadata through Mod:metadata {}")
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

