-- Physics engine based on AABB.

local common = require "common"
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
  function Body:init(world, size, density, owner)
    assert(world:of(World))
    assert(size ~= nil)
    assert(density ~= nil)

    self.owner = owner -- user-specified owner object
    self.world = world
    self.size = size
    self.position = Vec(0, 0)
    self.positionPrev = Vec(0, 0)
    self.velocity = Vec(0, 0)
    self.force = Vec(0, 0)
    self.elasticity = 0
    self:setDensity(density)
    self.collidingWith = {}
    self.onCollisionWithBody = common.noop
  end

  -- Removes the body from its physics world immediately.
  -- Bodies are normally removed from the world as soon as they get garbage
  -- collected, which might not be predictable.
  -- This will remove the body during the next physics tick.
  --
  -- This also unsets the `owner` field of the body to ensure that no cycle is
  -- formed during garbage collection.
  function Body:drop()
    self._doDrop = true
    self.owner = nil
  end

  -- Changes the body's mass to use the provided density.
  function Body:setDensity(density)
    self.mass = self.size.x * self.size.y * density
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
  -- `density` specifies how dense the object should be. The mass of the object
  -- is calculated based off of this value and the object's volume (or rather,
  -- area, as we're dealing with 2D here).
  -- `owner` is a user-specified value that can be accessed via `body.owner`.
  function World:newBody(size, density, owner)
    local body = Body:new(self, size, density, owner)
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
  local function isSolid(blockID)
    return game.blocks[blockID] ~= nil and game.blocks[blockID].isSolid
  end

  World.isIDSolid = isSolid

  -- Returns whether the block at the given position is solid.
  function World:isSolid(position)
    return isSolid(self:block(position))
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

  local function resolveBodyCollision(self, bodyA, bodyB)
    bodyA.onCollisionWithBody(bodyB)
    bodyB.onCollisionWithBody(bodyA)
  end

  -- Speeds up collision resolution a bit
  jit.on(resolveBlockX)
  jit.on(resolveBlockY)
  jit.on(resolveBlockCollision)
  jit.on(resolveBodyCollision)

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

    local ownRect = body:rect()
    for _, other in ipairs(self.bodies) do
      if body ~= other then
        local otherRect = other:rect()
        if ownRect:intersects(otherRect) then
          resolveBodyCollision(self, body, other)
        end
      end
    end
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

  -- Returns the shortest delta position between the two points, taking the
  -- world seam into account. This should be used instead of b - a when dealing
  -- with entity coordinates, to ensure that distances between entities work
  -- properly.
  function World:shortestDelta(a, b)
    local left = Vec(b.x - self.unitWidth, b.y) - a
    local middle = b - a
    local right = Vec(b.x + self.unitWidth, b.y) - a
    local leftLen, middleLen, rightLen =
      left:len2(), middle:len2(), right:len2()
    if middleLen < leftLen and middleLen < rightLen then return middle end
    if leftLen < middleLen and leftLen < rightLen then return left end
    if rightLen < leftLen and rightLen < middleLen then return right end
    return middle -- failsafe!
  end

end
