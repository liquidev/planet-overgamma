-- Common UI-related things.

local rgba = love.math.colorFromBytes

local common = require "common"

local hex = common.hex

---

local style = {}

-- Accordion
style.accordionIcon = { hex "#ffffff" }
style.accordionTitle = { hex "#ffffff" }
style.accordionHover = { rgba(255, 255, 255, 64) }
style.accordionPressed = { rgba(255, 255, 255, 32) }

-- Item storage view
style.itemStorageCellOutline = { hex "#555555" }
style.itemStorageOutline = { hex "#333333" }
style.itemStorageEmptyText = { hex "#777777" }

-- Panel
style.panelFill = { hex "#101010" }
style.panelOutline = { hex "#ffffff" }

-- Progress bar
style.progressBackground = { hex "#555555" }
style.progressGreen = { hex "#7fec52" }
style.progressYellow = { hex "#ffc31f" }
style.progressRed = { hex "#fb4e4e" }
style.progressLightText = { hex"#ffffff" }
style.progressDarkText = { hex"#0a0724" }

return style
