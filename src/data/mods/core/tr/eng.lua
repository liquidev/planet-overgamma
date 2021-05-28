return {
  item = {
    ["core:plantMatter"] = "Plant Matter",
    ["core:stone"] = "Stone",
    ["core:rawCopper"] = "Raw Copper",
    ["core:copper"] = "Copper",
    ["core:rawTin"] = "Raw Tin",
    ["core:tin"] = "Tin",
  },
  block = {
    ["core:plants"] = "Plants",
    ["core:rock"] = "Rock",
  },
  worldGenerator = {
    ["core:canon"] = {
      name = "Canon",
      stage = {
        ["state.prep"] = "Preparing random state",
        ["heightmap.init"] = "Generating heightmap",
        ["heightmap.smooth"] = "Smoothing heightmap",
        ["heightmap.secondary"] = "Permuting secondary heightmaps",
        ["layer.surface"] = "Filling the surface",
        ["layer.rock"] = "Filling the rock layer",
      },
    },
  }
}
