-- World generators.

local common = require "common"
local Object = require "object"
local tables = require "tables"
local Vec = require "vec"
local World = require "world"

local round = common.round

---

local WorldGenerator = Object:inherit()

-- Initializes a new world generator.
-- name is a translatable string containing a user-friendly name for the
-- generator. The translation key for the name is as follows:
-- "worldGenerator/[name]/name".
function WorldGenerator:init(name)
  self._stages = {}
  self.name = name
  self.defaultConfig = {}
end

-- Specifies world generation stages.
--
-- stages is a table with the following structure:
-- {{
--   name: string,
--     -- A translatable name for the stage.
--   function (gen: WorldGenerator, world: World, config: any, ...): ...,
--     -- The function that performs the stage.
--     -- This function can call WorldGenerator:progress.
--     -- The function can pass a set of values through to the next stage by
--     -- returning them. The next stage will receive these values as extra
--     -- parameters to its function.
--     -- The values from the last stage are returned alongside the finished
--     -- world.
-- }}
--
-- Translation keys for world generator stages should be located under
-- "worldGenerator/[self.name]/stage/[stage.name]".
function WorldGenerator:stages(stages)
  self._stages = stages
end

-- Returns the number of stages for this world generator.
function WorldGenerator:stageCount()
  return #self._stages
end

local inStage = false

-- Reports progress about the current stage.
-- n must be a number between 0..1 (it is clamped to this range).
-- This function must only be used inside of a world generation stage.
function WorldGenerator:progress(n)
  assert(inStage,
         "WorldGenerator:progress can only be used in generation stages")
  coroutine.yield("progress", common.clamp(n, 0, 1))
end

-- Creates and returns a new iterator that generates a world.
-- The iterator can yield the following values:
--  · "stage", stage: number, description: string
--    Progress report that a new stage has just started.
--  · "progress", progress: number[0..1]
--    Progress report about how much of the current stage is finished.
--  · "done", world: World, ...
--    Progress report that the world generation has finished.
--    The extra return values are generator specific, and are a result of the
--    last stage.
-- config is a table with configuration options for the world generator.
-- This function only reads two config settings:
--  · width: number - a number divisible by World.Chunk.size that signifies
--    how large the world should be.
--  · gravity: Vec = Vec(0, 0.5) - the world's gravity.
function WorldGenerator:generate(config)
  config = tables.merge({}, self.defaultConfig, config)
  local world = World:new(config.width, config.gravity or Vec(0, 0.5))
  return coroutine.wrap(function ()
    local passthrough = {}
    for i, stage in ipairs(self._stages) do
      coroutine.yield("stage", i, stage.name)
      inStage = true
      passthrough = { stage[1](self, world, config, unpack(passthrough)) }
      inStage = false
    end
    coroutine.yield("done", world, unpack(passthrough))
  end)
end


--
-- Utility functions
--

-- Fills columns according to the heightmap, down to the specified bottom layer,
-- with the specified block.
-- Reports progress every column.
function WorldGenerator:fillHeightmap(world, heightmap, bottom, block)
  for x, maxY in ipairs(heightmap) do
    for y = round(maxY), bottom do
      world:block(Vec(x, y), block)
      self:progress(x / #heightmap)
    end
  end
end

-- Indexes the table with wrap-around behavior on indices not in 1 .. #t.
local function indexWrap(t, i)
  i = (i - 1) % #t + 1
  return t[i]
end

-- Applies a set of convolution kernels to the given table.
-- Note that this will modify the table. If you want a fresh table, create one
-- using tables.icopy.
function WorldGenerator.convolve(t, ...)
  local bufferA = t
  local bufferB = {}
  for k = 1, select('#', ...) do
    local kernel = select(k, ...)
    tables.fill(bufferB, #bufferA, 0)
    for i = 1, #bufferA do
      local center = math.floor(#kernel / 2)
      for j, w in ipairs(kernel) do
        local offset = j - center - 1
        bufferB[i] = bufferB[i] + indexWrap(bufferA, i + offset) * w
      end
    end
    bufferA, bufferB = bufferB, bufferA
  end
  if bufferA ~= t then
    bufferA, bufferB = bufferB, bufferA
    tables.icopy(bufferB, bufferA)
  end
  return bufferA
end

return WorldGenerator
