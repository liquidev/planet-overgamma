-- A fairly simple progress bar.

local style = require "ui.style"
local Ui = require "ui.base"

---

--- Maps the given value to a green/yellow/red progress bar color.
--- This can be used in conjunction with the color option in Ui:progress to
--- color the progress bar differently depending on the value.
---
--- @param value number            The value to map to a color.
--- @param yellowThreshold number  The minimum value for the color to be yellow.
--- @param redThreshold number     The minimum value for the color to be red.
--- @return Color
function Ui.mapProgressColor(value, yellowThreshold, redThreshold)

end

--- Draws a progress bar in a new group.
--- The options table contains settings for how the progress bar should be
--- rendered.
---
--- options can contain the following values:
---  · style: "thin" | "tall" - the style of the progress bar.
---    The thin progress bar normally takes up less space than the tall bar,
---    unless the label is present, in which case it takes up as much space as
---    the tall bar.
---  · color: Color - the fill color of the progress bar. Defaults to
---    style.progressGreen.
---  · label: string
---
--- @param value number   A number between 0..1 denoting the progress.
--- @param options table
function Ui:progress(value, options)
  options = options or {}
end

