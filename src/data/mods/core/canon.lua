-- The "Canon" world generator.

local lmath = love.math

local floor = math.floor
local sqrt = math.sqrt
local sin, cos = math.sin, math.cos
local pi = math.pi

local common = require "common"
local game = require "game"
local Registry = require "registry"
local tables = require "tables"
local Vec = require "vec"
local WorldGenerator = require "world.generation"
local World = require "world"

local deg = common.degToRad
local lerp = common.lerp

local Chunk = World.Chunk

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

  -- Ores.
  ores = {
    {
      -- The named ID of the ore.
      ore = "core:coal",
      -- The layers between which the ore can spawn.
      -- These are rounded down to multiples of 8.
      high = 0, low = 48,
      -- Number of spawn attempts per chunk, and the chance for each attempt
      -- to succeed.
      attemptCount = 1, spawnChance = 0.1,
      -- The length (amount of brush steps) of each vein,
      -- amount of ore per brush step, brush radius, and maximum amount
      -- for each tile.
      veinLength = 10, veinAmount = 5, veinRadius = 1,
      -- The set of blocks this ore is allowed to spawn on.
      allowOn = { ["core:rock"] = true },
    },
    {
      ore = "core:tin",
      high = 32, low = 128,
      attemptCount = 1, spawnChance = 0.075,
      veinLength = 2, veinAmount = 3, veinRadius = 2,
      allowOn = { ["core:rock"] = true },
    },
    {
      ore = "core:copper",
      high = 32, low = 128,
      attemptCount = 1, spawnChance = 0.05,
      veinLength = 3, veinAmount = 3, veinRadius = 2,
      allowOn = { ["core:rock"] = true },
    }
  },
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
  -- We take our generated heightmaps and fill in all the layers.
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

      return s
    end
  },
  {
    -- Generate positions where ores can spawn.
    name = "ores.positions",
    function (gen, world, config, s)
      local positionsPerOre = {}
      local widthInChunks = floor(world.width / Chunk.size)
      local count = 0

      for i, spec in ipairs(config.ores) do
        local positions = {}
        local high, low =
          floor(spec.high / Chunk.size), floor(spec.low / Chunk.size)
        for chunkX = 0, widthInChunks do
          for chunkY = high, low do
            for _ = 1, spec.attemptCount do
              if s.rng:random() < spec.spawnChance then
                local cx, cy = chunkX * Chunk.size, chunkY * Chunk.size
                local ox = s.rng:random(0, Chunk.size - 1)
                local oy = s.rng:random(0, Chunk.size - 1)
                local x, y = cx + ox, cy + oy
                table.insert(positions, Vec(x, y))
                count = count + 1
              end
            end
          end
        end
        positionsPerOre[i] = positions
        gen:progress(i / #config.ores)
      end

      return s, positionsPerOre, count
    end
  },
  {
    -- Generate ore veins.
    name = "ores.veins",
    function (gen, world, config, s, positionsPerOre, positionCount)
      local noiseZ = s.rng:random(1, 10000) + 0.5
      local positionIndex = 1

      for i, positions in ipairs(positionsPerOre) do
        local spec = config.ores[i]
        local oreID = game.oreIDs[spec.ore]
        local ore = game.ores[oreID]
        local radius = spec.veinRadius
        local radius2 = radius * radius
        local amount = spec.veinAmount
        local limit = ore.saturatedAt
        local allowOn = tables.kmap(
          spec.allowOn,
          function (k) return game.blockIDs[k] end
        )
        for _, position in ipairs(positions) do
          local angle = s.rng:random() * 2 * pi
          position = position:round()
          local length = s.rng:random(1, spec.veinLength)
          for step = 1, length do
            -- Fill the ores.
            for ox = -radius, radius - 1 do
              local height = sqrt(radius2 - ox * ox)
              for oy = -height, height - 1 do
                local origin = position:round()
                local point = origin + Vec(ox, oy)
                if allowOn[world:block(point)] then
                  world:addOre(point, oreID, amount, limit)
                end
              end
            end
            -- Step the position.
            position:add(Vec.fromAngle(angle))
            -- Increment angle by a random amount.
            local nposition =
              noiseCircle(s, step / spec.veinLength * 0.25, 5)
            local angleIncrement =
              lmath.noise(nposition.x, nposition.y, noiseZ) * 2 - 1
            angle = angle + deg(angleIncrement * 22.5)
          end
          noiseZ = noiseZ + 1
          positionIndex = positionIndex + 1
          gen:progress(positionIndex / positionCount)
        end
      end
    end
  }
}

return canon
