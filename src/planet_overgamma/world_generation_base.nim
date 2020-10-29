## Breaking module dependencies since 2019™
##
## You shouldn't really need this module in most cases. This only defines
## registry types for game_registry so that we don't run into recursive module
## dependency problems.
##
##     Nim no like recursive module dependency. Recursive module dependency bad.
##
##     ~ the Nim compiler, 2020

import parameters
import registry

type
  BaseWorldGenerator* = ref object of RootObj
    parameters*: Parameters

  WorldGeneratorId* = RegistryId[BaseWorldGenerator]
  WorldGeneratorRegistry* = Registry[BaseWorldGenerator]
