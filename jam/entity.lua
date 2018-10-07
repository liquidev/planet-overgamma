Entity = {}
Entity.__index = Entity
Entity.supertype = 'entity'

Entity.sprite = 'placeholder'

function Entity:_create(x, y, map)
    self._exists = false

    self.map = map
    self.age = 0

    self.pos = Vector:new(x, y)
    self.vel = Vector:new()
    self.acc = Vector:new()
    self.friction = 0

    self.sprframe = 0
    self.hitboxsize = { 8, 8 }

    self.scale = Vector:new(1, 1)
    self.rotation = 0

    self.remove = false

    return self
end

function Entity:new(o, x, y, map)
    o = o or {}
    setmetatable(o, self)
    self = o

    self:_create(x, y, map)

    self._exists = true
    self:init()

    return self
end

function Entity:extend()
    o = {}
    setmetatable(o, self)
    self = o

    return Entity._create(self, 0, 0, nil)
end

function Entity:init() end

function Entity:drawSprite()
    atl = jam.assets.sprites[self.sprite]
    love.graphics.draw(
            atl.image, atl.quads[math.floor(1 + self.sprframe % #atl.quads)],
            self.pos.x, self.pos.y,
            self.rotation,
            self.scale.x, self.scale.y,
            atl.spritesize[1] / 2, atl.spritesize[2] / 2)
end

function Entity:draw()
    self:drawSprite()
end

function Entity:update(dt)
    if self.map then self:physics(dt) end
    self.age = self.age + 1
end

function Entity:collideTile(tile) end

function Entity:collideEntity(entity) end

function Entity:physics(dt)
    self.vel:add(self.acc)
    self.acc:mul(0)

    local chpos = self.pos:copy()
    chpos:add(Vector:new(self.vel.x, 0))

    -- TODO: clean up this mess

    hitbox = Hitbox:new(
            chpos.x - self.hitboxsize[1] / 2, chpos.y - self.hitboxsize[2] / 2,
            self.hitboxsize[1], self.hitboxsize[2])

    self.map:eachSolid(function (tile)
        if self.vel.x > 0.001 and not self.map:getSolid(tile.x - 1, tile.y) then
            left = Hitbox:new(
                    tile.x * Map.tilesize[1], tile.y * Map.tilesize[2] + 1,
                    Map.tilesize[1] * 0.6, Map.tilesize[2] - 3)
            if hitbox:collides(left) then
                self.vel:mul(-self.friction, 1)
                chpos.x = left:left() - hitbox.width / 2
                self:collideTile(tile)
            end
        end
        if self.vel.x < -0.001 and not self.map:getSolid(tile.x + 1, tile.y) then
            right = Hitbox:new(
                    tile.x * Map.tilesize[1] + Map.tilesize[1] * 0.4, tile.y * Map.tilesize[2] + 1,
                    Map.tilesize[1] * 0.6, Map.tilesize[2] - 3)
            if hitbox:collides(right) then
                self.vel:mul(-self.friction, 1)
                chpos.x = right:right() + hitbox.width / 2
                self:collideTile(tile)
            end
        end
    end)

    chpos:add(Vector:new(0, self.vel.y))

    hitbox = Hitbox:new(
            chpos.x - self.hitboxsize[1] / 2, chpos.y - self.hitboxsize[2] / 2,
            self.hitboxsize[1], self.hitboxsize[2])

    self.map:eachSolid(function (tile)
        if self.vel.y > 0.001 and not self.map:getSolid(tile.x, tile.y - 1) then
            top = Hitbox:new(
                    tile.x * Map.tilesize[1] + 1, tile.y * Map.tilesize[2],
                    Map.tilesize[1] - 3, Map.tilesize[2] * 0.6)
            if hitbox:collides(top) then
                self.vel:mul(1, -self.friction)
                chpos.y = top:top() - hitbox.height / 2
                self:collideTile(tile)
            end
        end
        if self.vel.y < -0.001 and not self.map:getSolid(tile.x, tile.y + 1) then
            bottom = Hitbox:new(
                    tile.x * Map.tilesize[1] + 1, tile.y * Map.tilesize[2] + Map.tilesize[2] * 0.4,
                    Map.tilesize[1] - 3, Map.tilesize[2] * 0.6)
            if hitbox:collides(bottom) then
                self.vel:mul(1, -self.friction)
                chpos.y = bottom:bottom() + hitbox.height / 2
                self:collideTile(tile)
            end
        end
    end)

    self.pos:set(chpos.x, chpos.y)

    self.map:eachEntity(function (entity)
        if entity ~= self then
            selfbox = Hitbox:new(
                    self.pos.x - self.hitboxsize[1] / 2, self.pos.y - self.hitboxsize[2] / 2,
                    self.hitboxsize[1], self.hitboxsize[2])
            entbox = Hitbox:new(
                    entity.pos.x - entity.hitboxsize[1] / 2, entity.pos.y - entity.hitboxsize[2] / 2,
                    entity.hitboxsize[1], entity.hitboxsize[2])
            if selfbox:collides(entbox) then self:collideEntity(entity) end
        end
    end)

    if self.speed then
        if self.vel.x > self.speed then self.vel.x = self.speed end
        if self.vel.y > self.speed then self.vel.y = self.speed end
    end
end

function Entity:force(f)
    self.acc:add(f)
end

return Entity
