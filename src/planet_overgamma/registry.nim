## Generic registry for named stuff.

import std/tables

type
  IdBase = uint32

  RegistryId*[T] = distinct IdBase
    ## A registry element identifier.

  Registry*[T] = object
    ## Name-ID-resource registry.
    nameToId: Table[string, RegistryId[T]]
    idToName: seq[string]
    idToResource: seq[T]

  NameError* = object of ValueError
    ## Raised when an ID cannot be looked up by name.

proc `$`*[T](id: RegistryId[T]): string =
  ## Stringifies the given ID.
  $T & '(' & $IdBase(id) & ')'

proc `==`*[T](a, b: RegistryId[T]): bool =
  ## Compares the two IDs for equality.
  # {.borrow.} doesn't want to work with generics.
  IdBase(a) == IdBase(b)

proc register*[T](reg: var Registry[T], name: string,
                  resource: sink T): RegistryId[T] =
  ## Registers a name and returns its unique ID.

  result = RegistryId[T](reg.idToName.len)
  reg.nameToId[name] = result
  reg.idToName.add(name)
  reg.idToResource.add(resource)

proc id*[T](reg: Registry[T], name: string): RegistryId[T] =
  ## Returns the ID for the given name. Raises an exception if the ID doesn't
  ## exist.

  if name notin reg.nameToId:
    raise newException(NameError, $T & " with name " & name &
                                  " doesn't exist")
  reg.nameToId[name]

proc name*[T](reg: Registry[T], id: RegistryId[T]): string =
  ## Returns the name corresponding to this ID. Raises an exception if the ID is
  ## invalid (wasn't returned by this registry).

  let i = int(id)
  if i notin 0..<reg.idToName.len:
    raise newException(NameError, "invalid ID: " & $id)
  reg.idToName[i]

proc get*[T](reg: Registry[T], id: RegistryId[T]): lent T =
  ## Returns a reference to the resource with the given ID.

  let i = int(id)
  if i notin 0..<reg.idToName.len:
    raise newException(NameError, "invalid ID: " & $id)
  reg.idToResource[i]

proc get*[T](reg: var Registry[T], id: RegistryId[T]): var T =
  ## Returns a mutable reference to the resource with the given ID.

  let i = int(id)
  if i notin 0..<reg.idToName.len:
    raise newException(NameError, "invalid ID: " & $id)
  reg.idToResource[i]

proc get*[T](reg: Registry[T], name: string): lent T =
  ## Returns a mutable reference to the resource with the given name.
  ## **This procedure is slow** and should be avoided in hot loops. Instead,
  ## pre-fetch the ID before the loop and use it to access the resource.
  reg.get(reg.id(name))

proc get*[T](reg: var Registry[T], name: string): var T =
  ## Returns a mutable reference to the resource with the given name.
  ## **This procedure is slow** and should be avoided in hot loops. Instead,
  ## pre-fetch the ID before the loop and use it to access the resource.
  reg.get(reg.id(name))
