-- Internationalization (i18n) support.

local common = require "common"
local tables = require "tables"

---

local i18n = {}
local lang = {}
local lookupCache = {}
local modules = {"tr"}

-- Adds translations directly to the lookup table.
-- Since this is not very multilanguage-friendly, translation modules should
-- be preferred over this.
function i18n.add(translations)
  tables.merge(lang, translations)
end

-- Adds a module directory that should be used for loading translation files.
--
-- This module directory should be a require-compatible path (using dots '.'
-- instead of slashes '/' for subdirectories), that contains .lua files named
-- after ISO 639-2 language codes.
--
-- Each of these files must return a table with translations. When loading
-- a language, one of the previously mentioned .lua files, named after the
-- selected country code, is loaded via require. The table this module returns
-- is merged with the main translations table by using i18n.add.
function i18n.addModule(module)
  table.insert(modules, module)
end

-- Loads a language with the given ISO 639-2 language code.
-- All previously present strings are removed upon calling this.
function i18n.loadLanguage(code)
  print("loading language: '"..code.."'")
  lang = {}
  lookupCache = {}
  for _, parentModule in ipairs(modules) do
    local module = parentModule..'.'..code
    print("language module: '"..module.."'")
    local ok, result = common.try(require, module)
    if ok then
      assert(type(result) == "table",
             "translation module '"..module.."' did not return a table")
      i18n.add(result)
    else
      print("error: couldn't load translations from '"..module.."': "..result)
    end
  end
end

-- Translates the given key, or if no translation is available, returns the key.
-- Lookup paths should be separated by slashes '/'.
function i18n.tr(path)
  if lookupCache[path] then return lookupCache[path] end

  local tab = lang
  for comp in path:gmatch("[^/]+") do
    tab = tab[comp]
    if tab == nil then return path end
  end
  lookupCache[path] = tab
  return tab
end

return i18n
