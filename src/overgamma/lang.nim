#--
# Planet Overgamma
# a game about planets, machines, and robots.
# copyright (C) 2018-19 iLiquid
#--

import os
import parsecfg
import streams
import strtabs

import debug
import res

type
  LanguageError* = object of Exception

var lang: StringTableRef

proc L*(key: string): string =
  ## Returns the language string ``key``.
  result =
    if key in lang: lang[key]
    else: key

proc loadLanguage*(dir: string, prefix = "") =
  ## Loads the current language from ``dir``, prepending keys with
  ## ``{prefix}.`` as a form of primitive namespacing.
  if lang == nil:
    verbose("Creating", "new language string table")
    lang = newStringTable(modeStyleInsensitive)
  info("Loading", "language: " & prefix & "/" & settings.general.language)
  var langFs = newFileStream(dir/settings.general.language & ".cfg")
  if langFs == nil:
    error("Error:", "could not find language file " & settings.general.language)
    return
  let prefix =
    if prefix.len == 0: ""
    else: prefix & '.'
  var
    parser: CfgParser
    parseError = false
    section = "."
    keys = 0
  parser.open(langFs, settings.general.language & ".cfg")
  while true:
    let ev = parser.next()
    case ev.kind
    of cfgEof: break
    of cfgError:
      parseError = true
      error("Lang/error:",
            parser.getFilename(), "(", parser.getLine(), "): ", ev.msg)
    of cfgOption:
      parseError = true
      error("Lang/error:",
            parser.getFilename(), "(", parser.getLine(), "): " &
            "Options are not supported in language files")
    of cfgSectionStart:
      section = ev.section
    of cfgKeyValuePair:
      lang[prefix & section & ' ' & ev.key] = ev.value
      inc(keys)
  if parseError:
    raise newException(LanguageError,
                       "errors occured while loading language from " & dir)
  parser.close()
  verbose(settings.general.language & ":", $keys, " keys total")
