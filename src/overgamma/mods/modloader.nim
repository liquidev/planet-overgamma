import os
import parsecfg
import streams
import strutils
import tables

import euwren

import ../debug
import ../res
import moddef

# APIs, imported in the correct order to not cause any errors.
# this order is determined by every API's dependencies, eg.
# poapi needs rapidapi, so rapidapi must come first
import rapidapi
import poapi

proc modAssert(cond: bool, errorMsg = "assertion failed") =
  if not cond:
    raise newException(ModError, errorMsg)

proc readModCfg(m: Mod) =
  info("Reading", "mod.cfg from ", m.path)
  var
    parser: CfgParser
    stream = newFileStream(m.path/"mod.cfg", fmRead)
    section = ""
    errors = ""
  if stream == nil:
    raise newException(ModError, "could not load mod.cfg from " & m.path)
  parser.open(stream, "mod.cfg")

  proc error(msg: string) =
    errors.add(parser.errorStr(msg) & '\n')

  var name, author, version, description, index = ""
  while true:
    let ev = parser.next()
    case ev.kind
    of cfgEof: break
    of cfgOption: error("unexpected option")
    of cfgError: error(ev.msg)
    of cfgSectionStart: section = ev.section
    of cfgKeyValuePair:
      case section
      of "Metadata":
        case ev.key
        of "name": name = ev.value
        of "author": author = ev.value
        of "version": version = ev.value
        of "description": description = ev.value
        else: error("invalid property")
      of "Mod":
        case ev.key
        of "index": index = ev.value
      else:
        error("invalid section")
  m.initMetadata(name, author, version, description)
  header("Mod: ", m.codename, " - ", m.name)
  verbose("Version", m.version)
  verbose("Author", m.author)
  if m.description != "":
    verbose("Description", m.description.replace('\n', ' '))
  info("Initializing", "VM")
  m.initVM(index)

proc wrenMods*(wren: Wren) =
  wrenRapid(wren)
  wrenPO(wren)
  wren.ready()

proc loadMod*(path: string): Mod =
  new(result)
  result.init(path, codename = splitPath(path).tail)
  result.readModCfg()
  modAssert result.name != "", "mod must have a name"
  modAssert result.author != "", "mod must have an author"
  modAssert result.version != "", "mod must have a version"
  modAssert result.index != "", "mod must have an index file"
  wrenMods(result.wren)

proc loadMods*(to: var Table[string, Mod], fromDir: string) =
  for pc, path in walkDir(fromDir):
    if pc == pcDir:
      if fileExists(path/"mod.cfg"):
        let m = loadMod(path)
        to[m.codename] = m

proc initMods*(mods: Table[string, Mod]) =
  info("Running", "module init scripts")
  for name, m in mods:
    let
      indexModuleName = m.index.splitFile().name
      indexModuleSrc = readFile(m.path/m.index)
    # TODO: report an error in case of failue, instead of crashing
    verbose("Script", m.codename/m.index)
    m.wren.module(indexModuleName, indexModuleSrc)

