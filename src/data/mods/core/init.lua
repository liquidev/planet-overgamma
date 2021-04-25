-- The core mod.

local mod = ...
mod:metadata {
  name = "Core",
  version = "0.1.0",
  author = "liquidev",
  description = "The core mechanics of the game.",
}

local blocks = {
  plants = mod:addBlock("plants", "blocks/plants.png"),
  rock = mod:addBlock("rock", "blocks/rock.png"),
}

return {
  blocks = blocks,
}
