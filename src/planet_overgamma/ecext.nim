## rapid/ec extensions.

import rapid/ec
import rapid/graphics

import camera
import resources
import ui

export ec

type
  ExtComponent* = object of RootComponent
    ## An extended component with extra, Overgamma-specific fields.
    g*: Game
    extImpl*: ExtComponentImpl

  ExtComponentLateUpdate*[C: ExtComponent] =
    proc (comp: var C, camera: var Camera) {.nimcall.}
    ## *Late* update, done after physics are processed.

  ExtComponentUpdate*[C: ExtComponent] =
    proc (comp: var C, camera: var Camera) {.nimcall.}
    ## Extended updates with a camera.

  ExtComponentShape*[C: ExtComponent] =
    proc (comp: var C, graphics: Graphics, camera: Camera,
          step: float32) {.nimcall.}
    ## Extended shape-rendering with a camera.

  ExtComponentUiPanel*[C: ExtComponent] =
    proc (comp: var C, ui: GameUi, expanded: bool) {.nimcall.}
    ## UI rendering on the panel.

  ExtComponentImpl* = object
    ## An object holding all the extended callbacks a component can implement.

    lateUpdate*: ExtComponentLateUpdate[ExtComponent]
    update*: ExtComponentUpdate[ExtComponent]
    shape*: ExtComponentShape[ExtComponent]
    uiPanel*: ExtComponentUiPanel[ExtComponent]

  ExtEntity* = ref object of RootEntity
    ## Extended entity with game resource access.
    g*: Game


# callbacks

{.push inline.}

proc onLateUpdate*[T: ExtComponent](comp: var T,
                                    impl: ExtComponentLateUpdate[T]) =
  comp.extImpl.lateUpdate = cast[ExtComponentLateUpdate[ExtComponent]](impl)

proc onUpdate*[T: ExtComponent](comp: var T, impl: ExtComponentUpdate[T]) =
  comp.extImpl.update = cast[ExtComponentUpdate[ExtComponent]](impl)

proc onShape*[T: ExtComponent](comp: var T, impl: ExtComponentShape[T]) =
  comp.extImpl.shape = cast[ExtComponentShape[ExtComponent]](impl)

proc onUiPanel*[T: ExtComponent](comp: var T, impl: ExtComponentUiPanel[T]) =
  comp.extImpl.uiPanel = cast[ExtComponentUiPanel[ExtComponent]](impl)


{.pop.}

proc autoImplement*(comp: var ExtComponent)
  {.error: "use autoImplementExt on ExtComponents".}

proc autoImplementExt*[T: ExtComponent](comp: var T) =
  ## Automagically implement any callbacks, depending on what procs have been
  ## declared at callsite. This also handles ExtComponent-specific callbacks.

  template attempt(stmt) =
    when compiles(stmt):
      stmt

  ec.autoImplement(comp)

  attempt:
    mixin componentLateUpdate
    comp.onLateUpdate ExtComponentLateUpdate[T](componentLateUpdate)
  attempt:
    mixin componentUpdate
    comp.onUpdate ExtComponentUpdate[T](componentUpdate)
  attempt:
    mixin componentShape
    comp.onShape ExtComponentShape[T](componentShape)
  attempt:
    mixin componentUiPanel
    comp.onUiPanel ExtComponentShape[T](componentUiPanel)


proc lateUpdate*(entity: RootEntity, camera: var Camera) =
  ## Late-updates the entity's components.

  for comp in components(entity):
    if comp of ExtComponent:
      var extComp = addr comp.ExtComponent
      if extComp.extImpl.lateUpdate != nil:
        extComp.extImpl.lateUpdate(extComp[], camera)

proc update*(entity: RootEntity, camera: var Camera) =
  ## Updates the entity's components.

  ec.update(entity)
  for comp in components(entity):
    if comp of ExtComponent:
      var extComp = addr comp.ExtComponent
      if extComp.extImpl.update != nil:
        extComp.extImpl.update(extComp[], camera)

proc shape*(entity: RootEntity, graphics: Graphics, camera: Camera,
            step: float32) =
  ## Shape-renders all of the entity's components.

  ec.shape(entity, graphics, step)
  for comp in components(entity):
    if comp of ExtComponent:
      var extComp = addr comp.ExtComponent
      if extComp.extImpl.shape != nil:
        extComp.extImpl.shape(extComp[], graphics, camera, step)

proc uiPanel*(entity: RootEntity, ui: GameUi, expanded: bool) =
  ## Renders the side panel UI of all of the entity's components.

  for comp in components(entity):
    if comp of ExtComponent:
      var extComp = addr comp.ExtComponent
      if extComp.extImpl.uiPanel != nil:
        extComp.extImpl.uiPanel(extComp[], ui, expanded)


proc lateUpdate*(entities: seq[RootEntity], camera: var Camera) =
  ## Late-updates all entities in the sequence.

  for entity in entities:
    entity.lateUpdate(camera)

proc update*(entities: seq[RootEntity], camera: var Camera) =
  ## Updates all entities in the sequence.

  for entity in entities:
    entity.update(camera)

proc shape*(entities: seq[RootEntity], graphics: Graphics, camera: Camera,
            step: float32) =
  ## Shape-renders all entities in the sequence.

  for entity in entities:
    entity.shape(graphics, camera, step)

proc uiPanel*(entities: seq[RootEntity], ui: GameUi, expanded: bool) =
  ## Renders the side panel UI of all entities in the sequence.

  for entity in entities:
    entity.uiPanel(ui, expanded)

proc initExtEntity*[T: ExtEntity](entity: T, g: Game) =
  ## Initializes an ExtEntity. The entity must not be nil.

  entity.g = g
  for component in fields(entity[]):
    when component is ExtComponent:
      component.g = g
