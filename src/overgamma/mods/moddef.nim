import os

import euwren

type
  Mod* = ref object
    # Info
    path, codename: string
    # Metadata
    name, author, version, description, index: string
    # VM
    wren: Wren
  ModError* = object of CatchableError

proc path*(m: Mod): string = m.path
proc codename*(m: Mod): string = m.codename

proc name*(m: Mod): string = m.name
proc author*(m: Mod): string = m.author
proc version*(m: Mod): string = m.version
proc description*(m: Mod): string = m.description

proc wren*(m: Mod): Wren = m.wren
proc index*(m: Mod): string = m.index

proc init*(m: Mod, path, codename: string) =
  ## 1st step of initializing a mod: set its path and codename.
  m.path = path
  m.codename = codename

proc initMetadata*(m: Mod, name, author, version, description: string) =
  ## Set the metadata of the mod.
  m.name = name
  m.author = author
  m.version = version
  m.description = description

proc initVM*(m: Mod, index: string) =
  ## Initialize the mod's VM, this does not run the provided index script.
  m.index = index
  m.wren = newWren()
  m.wren.onLoadModule do (name: string) -> string:
    let filename =
      if name.len > 0 and name[0] == '/':
        # absolute path
        m.path/../name
      else:
        # relative path
        m.path/name
    result = readFile(addFileExt(filename, "wren"))
  m.wren.onResolveModule do (importer, name: string) -> string:
    if name.len > 0 and name[0] in {'/', '.'}:
      # API or absolute path
      result = name
    else:
      # relative path
      result = importer/name

