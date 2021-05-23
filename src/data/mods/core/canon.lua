-- The "Canon" world generator.

local lmath = love.math

local sin, cos = math.sin, math.cos
local pi = math.pi

local common = require "common"
local game = require "game"
local tables = require "tables"
local Vec = require "vec"
local WorldGenerator = require "world.generation"

local lerp = common.lerp

---

local canon = WorldGenerator:new("canon")

canon.defaultConfig = {
  width = 256,
  gravity = Vec(0, 0.5),

  -- The seed to use with random generation.
  seed = nil,

  -- The layers of the world.
  surfaceBottom = 8,
  surfaceTop = -16,
  rockTop = 8,
  rockBottom = 128,

  -- Heightmap configuration.
  heightNoiseRadius = 3, -- aka noise density

  -- Plant configuration.
  weedNoiseRadius = 5,

  -- Tiles.
  surfaceTile = "core:plants",
  rockTile = "core:rock",
  weedsTile = "core:weeds",
}

-- Computes fractal noise with the given number of octaves, at the given
-- coordinates.
local function fractalNoise(octaves, x, y, z)
  z = z or 0.5
  local result = 0
  for i = 1, octaves do
    local factor = i * i
    local noise = lmath.noise(x * factor, y * factor, z + i * 0.1)
    result = result + noise / factor
  end
  return math.abs(result)
end

-- Convolution kernels.
local boxBlur3 = { 1/3, 1/3, 1/3 }
local boxBlur5 = { 1/5, 1/5, 1/5, 1/5, 1/5 }

-- Creates a generation stage for a terrain layer.
local function terrainLayer(name)
  return {
    name = "layers."..name,
    function (gen, world, config, s, heightmaps)
      local surface = game.blockIDs[config[name.."Tile"]]
      local bottom = config[name.."Bottom"] or 0
      gen:fillHeightmap(world, heightmaps[name], bottom, surface)
      return s, heightmaps
    end
  }
end

-- Permutes the heightmap through an offset and a set of kernels specified
-- in varargs.
local function permuteHeightmap(heightmap, offset, ...)
  return WorldGenerator.convolve(
    tables.imap(
      tables.icopy(heightmap),
      function (x) return x + offset end
    ),
    ...
  )
end

-- Returns coordinates for sampling noise in a circle around s.noiseOrigin.
local function noiseCircle(s, t, radius)
  local angle = t * 2 * pi
  local offset = Vec(sin(angle) * radius, cos(angle) * radius)
  return s.noiseOrigin + offset + Vec(0.5, 0.5)
end

canon:stages {
  {
    -- Prep work before we begin generating the world. This sets up
    -- shared state used across different states.
    name = "state.prep",
    function (_, _, config)
      local seed = config.seed or os.time()
      print("seed: "..seed)
      local rng = lmath.newRandomGenerator(seed)
      local noiseOrigin = Vec(rng:random(100, 100000), rng:random(100, 100000))
      return { rng = rng, noiseOrigin = noiseOrigin }
    end
  },
  {
    -- We generate a basic heightmap using Perlin noise.
    name = "heightmap.init",
    function (gen, world, config, s)
      local heightmap = {}
      local r = config.heightNoiseRadius
      local low, high = config.surfaceBottom, config.surfaceTop
      for x = 1, config.width do
        local t = x / world.width
        local p = noiseCircle(s, t, r)
        local noise = lerp(low, high, fractalNoise(5, p.x, p.y, 1))
        heightmap[x] = noise
        gen:progress(t)
      end
      return s, heightmap
    end
  },
  {
    -- Then, smooth out the heightmap by convolving it with a 3-box blur.
    name = "heightmap.smooth",
    function (gen, world, config, s, heightmap)
      gen.convolve(heightmap, boxBlur3)
      return s, heightmap
    end
  },
  {
    -- Generate the secondary heightmaps.
    name = "heightmap.secondary",
    function (gen, world, config, s, heightmap)
      return s, {
        surface = heightmap,
        rock = permuteHeightmap(
          heightmap, config.rockTop,
          { 0.5, 0, 0.5, 0, 0 }, boxBlur5
        ),
      }
    end
  },
  -- We take our generated heightmaps and fill all the individual layers.
  terrainLayer "surface",
  terrainLayer "rock",
  {
    -- Generate weeds on the surface.
    name = "decoration.weeds",
    function (gen, world, config, s, heightmaps)
      local r = config.weedNoiseRadius
      local weeds = game.blockIDs[config.weedsTile]
      for x = 1, world.width do
        local t = x / world.width
        local p = noiseCircle(s, t, r)
        local noise = lmath.noise(p.x, p.y, 3)
        if s.rng:random() < noise then
          local y = common.round(heightmaps.surface[x]) - 1
          world:setBlock(Vec(x, y), weeds)
        end
        gen:progress(t)
      end
    end
  },
}

return canon
