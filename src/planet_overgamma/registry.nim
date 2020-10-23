## Generic registry for named stuff.

import std/tables

type
  IdBase = uint32

  RegistryId*[Tag] = distinct IdBase
    ## A registry element identifier.

  Registry*[Tag] = object
    ## Name-ID registry.
    nameToId: Table[string, RegistryId[Tag]]
    idToName: seq[string]

  NameError* = object of ValueError
    ## Raised when an ID cannot be looked up by name.

proc `$`*[Tag](id: RegistryId[Tag]): string =
  ## Stringifies the given ID.
  $Tag & '(' & $IdBase(id) & ')'

proc `==`*[Tag](a, b: RegistryId[Tag]): bool =
  ## Compares the two IDs for equality.
  # {.borrow.} doesn't want to work with generics.
  IdBase(a) == IdBase(b)

proc register*[Tag](reg: var Registry[Tag], name: string): RegistryId[Tag] =
  ## Registers a name and returns its unique ID.

  result = RegistryId[Tag](reg.idToName.len)
  reg.nameToId[name] = result
  reg.idToName.add(name)

proc id*[Tag](reg: var Registry[Tag], name: string): RegistryId[Tag] =
  ## Returns the ID for the given name. Raises an exception if the ID doesn't
  ## exist.

  if name notin reg.nameToId:
    raise newException(NameError, $Tag & " with name " & name &
                                  " doesn't exist")
  reg.nameToId[name]

proc name*[Tag](reg: var Registry[Tag], id: RegistryId[Tag]): string =
  ## Returns the name corresponding to this ID. Raises an exception if the ID is
  ## invalid (wasn't returned by this registry).

  let i = int(id)
  if i notin 0..<reg.idToName.len:
    raise newException(NameError, "invalid ID: " & $id)
  reg.idToName[i]
