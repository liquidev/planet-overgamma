return {
  item = {
    ["core:plantMatter"] = "Plant Matter",
    ["core:stone"] = "Stone",
    ["core:rawCopper"] = "Raw Copper",
    ["core:copper"] = "Copper",
    ["core:rawTin"] = "Raw Tin",
    ["core:tin"] = "Tin",
    ["core:stoneChassis"] = "Stone Chassis",
    ["core:copperHeatPipe"] = "Copper Heat Pipe",
  },
  block = {
    ["core:plants"] = "Plants",
    ["core:rock"] = "Rock",
  },
  machine = {
    ["core:stoneFurnace"] = "Stone Furnace",
    ["core:stoneRefiner"] = "Stone Refiner",
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
