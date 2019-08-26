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

var lang: StringTableRef

proc L*(key: string): string =
  result =
    if key in lang: lang[key]
    else: key

proc loadLanguage*() =
  info("Loading", "language: " & settings.general.language)
  var langFs = newFileStream("data/lang"/settings.general.language & ".cfg")
  if langFs == nil:
    error("Error:", "could not find language file " & settings.general.language)
    quit(QuitFailure)
  lang = newStringTable(modeCaseSensitive)
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
            parser.getFilename(), ":", parser.getLine(), " ", ev.msg)
    of cfgOption:
      parseError = true
      error("Lang/error:",
            parser.getFilename(), ":", parser.getLine(),
            " Options are not supported in language files")
    of cfgSectionStart:
      section = ev.section
    of cfgKeyValuePair:
      lang[section & ' ' & ev.key] = ev.value
      inc(keys)
  if parseError: quit(QuitFailure)
  parser.close()
  verbose(settings.general.language & ":", $keys, " keys total")
  echo lang
