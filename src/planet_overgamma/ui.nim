## UI: controls and other stuff

import rapid/graphics
import rapid/ui

import items
import item_storage

export ui

type
  GameUi* = ref object of Ui
    ## UI with some extra game-specific fields.

    sansRegular*, sansBold*, sansItalic*, sansBoldItalic*: Font

    mouseOverPanel*: bool

  AccordionWindow* = object
    ## State for an accordion window.
    expanded*: bool

  ItemGrid* = ref object
    ## Item grid UI state.


const
  black* = hex"#0a0a0a"
  white* = hex"#ffffff"
  green* = hex"#06ca4a"
  yellow* = hex"#ffc31f"
  red* = hex"#db3030"

  panelPadding* = 8

template panel*(ui: GameUi, bsize: Vec2f, layout: BoxLayout, body: untyped) =
  ## Draws a black panel with a white outline.

  ui.box(bsize, blFreeform):
    ui.fill(black)
    ui.outline(white)

    ui.mouseHover:
      ui.mouseOverPanel = true

    ui.box(ui.size, layout):
      ui.pad(panelPadding)
      `body`

template accordionWindow*(ui: GameUi, window: AccordionWindow,
                          contentHeight: float32, layout: BoxLayout,
                          label: string, body: untyped) =
  ## Draws and processes events for an accordion window.
  const
    labelBoxHeight = 16
    spacing = 8
    labelHeight = panelPadding * 2 + labelBoxHeight
  let
    panelSize =
      vec2f(ui.width, labelHeight) +
      vec2f(0, spacing + contentHeight) * float32(window.expanded)

  ui.panel(panelSize, blVertical):
    ui.spacing = spacing
    ui.box(vec2f(ui.width, labelBoxHeight), blFreeform):
      ui.font = ui.sansBold
      ui.text(label, white, (apLeft, apMiddle))
      ui.mouseHover:
        if ui.mouseButtonIsDown(mbLeft):
          ui.bottomBorder(white.withAlpha(0.4))
        else:
          ui.bottomBorder(white.withAlpha(0.6))
    if window.expanded:
      ui.box(vec2f(ui.width, contentHeight), layout):
        `body`
    ui.currentBox.layoutPosition = vec2f(0, 0)
    ui.box(vec2f(ui.width, labelBoxHeight), blFreeform):
      ui.mouseReleased(mbLeft):
        window.expanded = not window.expanded

proc progressBar*(ui: GameUi, size: Vec2f, progress: float32,
                  color: Color, label = "") =
  ## Draws a progress bar.

  ui.box(size, blFreeform):
    ui.fill(white.withAlpha(0.15))

    let width = size.x * progress
    ui.box(vec2f(width, size.y), blFreeform):
      ui.fill(color)

    if label.len > 0:
      ui.box(vec2f(0, 1), ui.size, blFreeform):
        ui.text(label, black.withAlpha(0.6), (apCenter, apMiddle))
      ui.text(label, white, (apCenter, apMiddle))

proc itemGrid*(ui: GameUi, grid: var ItemGrid, storage: ItemStorage,
               columns: Positive, height: float32) =
  ## Draws an item grid and processes its events.

  const gridSize = 30

  let width = gridSize * columns.float32

  ui.box(vec2f(ui.width, height), blFreeform):
    ui.box(vec2f(width, height), blVertical):
      ui.align((apCenter, apTop))
      ui.outline(white.withAlpha(0.5))

