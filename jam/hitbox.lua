Hitbox = {}
Hitbox.__index = Hitbox

function Hitbox:new(x, y, width, height)
    local o = {}
    setmetatable(o, self)
    self = o

    self.x = x
    self.y = y
    self.width = width
    self.height = height

    return self
end

function Hitbox:left() return self.x end
function Hitbox:right() return self.x + self.width end
function Hitbox:top() return self.y end
function Hitbox:bottom() return self.y + self.height end

function Hitbox:collidesx(other)
    return self.x < other.x + other.width and
           other.x < self.x + self.width
end

function Hitbox:collidesy(other)
    return self.y < other.y + other.height and
           other.y < self.y + self.height
end

function Hitbox:collides(other)
    return self:collidesx(other) and self:collidesy(other)
end

function Hitbox:has(vector)
    return vector.x > self:left() and vector.x < self:right()
       and vector.y > self:top() and vector.y < self:bottom()
end

function Hitbox:draw()
    if jam.arg('%-h') then jam.scheduledraw(self) end
end

function Hitbox:_scheddraw()
    love.graphics.setColor(Color.rgb(255, 0, 0))
    love.graphics.rectangle('line',
            self.x + 0.5 - jam.activemap.scroll.x, self.y + 0.5 - jam.activemap.scroll.y, self.width, self.height)
    love.graphics.setColor(Color.rgb(255, 255, 255))
end
