-- Physics engine based on AABB.

local game = require "game"
local Object = require "object"
local Rect = require "rect"
local Vec = require "vec"

---

return function (World)

  local Chunk = World.Chunk

  --
  -- Body
  --

  local Body = Object:inherit()
  World.Body = Body

  -- Creates and initializes a new physics body with the given size.
  -- Use World:newBody instead of this.
  function Body:init(world, size, density)
    assert(world:of(World))
    assert(size ~= nil)
    assert(density ~= nil)

    self.world = world
    self.size = size
    self.position = Vec(0, 0)
    self.positionPrev = Vec(0, 0)
    self.velocity = Vec(0, 0)
    self.force = Vec(0, 0)
    self.elasticity = 0
    self.mass = size.x * size.y * density
    self.collidingWith = {}
  end

  -- Removes the body from its physics world immediately.
  -- Bodies are normally removed from the world as soon as they get garbage
  -- collected, which might not be predictable.
  -- This will remove the body during the next physics tick.
  function Body:drop()
    self._doDrop = true
  end

  -- Applies a force to the body.
  function Body:applyForce(force)
    self.force:add(force)
  end

  -- Returns the center point of the body.
  function Body:center()
    return self.position + self.size / 2
  end

  -- Returns the bounding box of the body.
  function Body:rect()
    return Rect:new(self.position, self.size)
  end

  -- Returns the rectangle stretching over the tiles the body occupies.
  function Body:tiles()
    return Rect.sides {
      left = math.floor(self.position.x / Chunk.tileSize),
      top = math.floor(self.position.y / Chunk.tileSize),
      right = math.floor((self.position.x + self.size.x) / Chunk.tileSize),
      bottom = math.floor((self.position.y + self.size.y) / Chunk.tileSize),
    }
  end

  -- Returns the interpolated position of the body. This should be used
  -- when rendering the body to avoid stuttering.
  function Body:interpolatePosition(t)
    return self.positionPrev:lerp(self.position, t)
  end

  --
  -- World functions
  --

  -- Initializes physics in the world. Called by world:init.
  function World:initPhysics(gravity)
    self.bodies = setmetatable({}, { mode = "v" })
    self.gravity = gravity
  end

  -- Creates a new physics body, adds it to the world, and returns it.
  -- `size` specifies the size of the body, in units.
  function World:newBody(size, density)
    local body = Body:new(self, size, density)
    table.insert(self.bodies, body)
    return body
  end

  -- Returns the rectangle that the block at the given position covers.
  function World:blockRect(position)
    return Rect:new(
      position * Chunk.tileSize,
      Vec(Chunk.tileSize, Chunk.tileSize)
    )
  end

  -- The minimum velocity required for collision detection to occur.
  local velocityEpsilon = 0.001

  -- Resolves collisions on the X axis.
  local function resolveBlockX(self, body, bodyRect, blockPosition)
    local blockRect = self:blockRect(blockPosition)
    local velocity = body.velocity.x
    if velocity > velocityEpsilon then
      local leftWall = Rect.sides {
        left = blockRect:left(),
        top = blockRect:top() + 1,
        right = blockRect:left() + velocity,
        bottom = blockRect:bottom() - 1,
      }
      if bodyRect:intersects(leftWall) then
        body.position.x = leftWall:left() - bodyRect.width
        body.velocity.x = body.velocity.x * -body.elasticity
        body.collidingWith.left = true
      end
    elseif velocity < -velocityEpsilon then
      local rightWall = Rect.sides {
        left = blockRect:right() + velocity,
        top = blockRect:top() + 1,
        right = blockRect:right(),
        bottom = blockRect:bottom() - 1,
      }
      if bodyRect:intersects(rightWall) then
        body.position.x = rightWall:right()
        body.velocity.x = body.velocity.x * -body.elasticity
        body.collidingWith.right = true
      end
    end
  end

  -- Resolves collisions on the Y axis.
  local function resolveBlockY(self, body, bodyRect, blockPosition)
    local blockRect = self:blockRect(blockPosition)
    local velocity = body.velocity.y
    if velocity > velocityEpsilon then
      local topWall = Rect.sides {
        left = blockRect:left() + 1,
        top = blockRect:top(),
        right = blockRect:right() - 1,
        bottom = blockRect:top() + velocity,
      }
      if bodyRect:intersects(topWall) then
        body.position.y = topWall:top() - bodyRect.height
        body.velocity.y = body.velocity.y * -body.elasticity
        body.collidingWith.top = true
      end
    elseif velocity < -velocityEpsilon then
      local bottomWall = Rect.sides {
        left = blockRect:left() + 1,
        top = blockRect:bottom() + velocity,
        right = blockRect:right() - 1,
        bottom = blockRect:bottom(),
      }
      if bodyRect:intersects(bottomWall) then
        body.position.y = bottomWall:bottom()
        body.velocity.y = body.velocity.y * -body.elasticity
        body.collidingWith.bottom = true
      end
    end
  end

  -- Returns whether the given block ID is of a solid block.
  local function isSolid(block)
    return block ~= 0 and game.blocks[block].isSolid
  end

  -- Wraps the unit X position of the body around the world.
  -- Also updates the body's previous position to prevent jank in interpolation.
  local function wrapAround(self, body)
    local x = body.position.x
    local width = self.width * Chunk.tileSize
    if x < 0 then
      body.position.x = x + width
      body.positionPrev:copy(body.position)
    elseif x > width then
      body.position.x = x - width
      body.positionPrev:copy(body.position)
    end
  end

  -- Resolves collisions between the body and the world.
  local function resolveBlockCollision(self, body)
    local bodyTiles, bodyRect

    body.position.x = body.position.x + body.velocity.x
    wrapAround(self, body)
    bodyRect = body:rect()
    bodyTiles = body:tiles()
    for y = bodyTiles:top(), bodyTiles:bottom() do
      for x = bodyTiles:left(), bodyTiles:right() do
        local position = Vec(x, y)
        local block = self:block(position)
        if isSolid(block) then
          resolveBlockX(self, body, bodyRect, position)
        end
      end
    end

    body.position.y = body.position.y + body.velocity.y
    bodyRect = body:rect()
    bodyTiles = body:tiles()
    for y = bodyTiles:top(), bodyTiles:bottom() do
      for x = bodyTiles:left(), bodyTiles:right() do
        local position = Vec(x, y)
        local block = self:block(position)
        if isSolid(block) then
          resolveBlockY(self, body, bodyRect, position)
        end
      end
    end
  end

  -- Speeds up collision resolution a bit
  jit.on(resolveBlockCollision)
  jit.on(resolveBlockX)
  jit.on(resolveBlockY)

  -- Updates a single physics body.
  local function updateBody(self, body)
    body.force:add(self.gravity * body.mass)

    body.positionPrev:copy(body.position)
    body.velocity:add(body.force)
    body.force:zero()

    body.collidingWith.left = false
    body.collidingWith.right = false
    body.collidingWith.top = false
    body.collidingWith.bottom = false
    resolveBlockCollision(self, body)
  end

  -- Ticks physics bodies in the world. Called by world:update.
  function World:updatePhysics()
    local i = 1
    local count = #self.bodies
    while i <= count do
      local body = self.bodies[i]
      if body._doDrop then
        self.bodies[i] = self.bodies[count]
        self.bodies[count] = nil
        count = count - 1
      else
        updateBody(self, body)
        i = i + 1
      end
    end
  end

end
