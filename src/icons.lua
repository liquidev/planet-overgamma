-- SVG icon handling.

local filesystem = love.filesystem
local graphics = love.graphics

local lovectorDOM = require "ext.lovector.svg.dom"
local lovectorCommon = require "ext.lovector.svg.common"
local lovectorGraphics = require "ext.lovector.graphics"

---

local icons = {}

-- Loads an SVG from the given source code.
local function loadSVG(source)
  local svg = {
    document = lovectorDOM.Document(source),
    width = 0,
    height = 0,
    graphics = lovectorGraphics()
  }
  lovectorCommon.gen(svg, svg.document.root, {
    debug = false,
    path_debug = false,
    stroke_debug = false,
  })
  return svg
end

-- Creates a new canvas with the highest possible rendering quality.
local function newCanvasHQ(width, height)
  local limits = graphics.getSystemLimits()
  local canvas = graphics.newCanvas(width, height, {
    msaa = limits.canvasmsaa,
  })
  return canvas
end

-- Transfers high quality canvas data onto a low quality canvas.
-- The source canvas is consumed in the process and cannot be used afterwards.
local function transferCanvas(sourceCanvas)
  local canvas = graphics.newCanvas(sourceCanvas:getDimensions())
  graphics.push("all")
  graphics.setCanvas(canvas)
  graphics.draw(sourceCanvas)
  graphics.pop()
  sourceCanvas:release()
  return canvas
end

-- Loads an icon and renders it to a canvas at the current DPI scale.
function icons.load(path)
  local source = filesystem.read(path)
  local svg = loadSVG(source)
  local canvas = newCanvasHQ(svg.width, svg.height)
  graphics.push("all")
  graphics.setCanvas { canvas, stencil = true }
  graphics.setLineStyle("smooth")
  svg.graphics:draw()
  graphics.pop()
  return transferCanvas(canvas)
end

return icons
