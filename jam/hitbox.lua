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

function Hitbox:draw()
    jam.scheduledraw(self)
end

function Hitbox:_scheddraw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('line',
            self.x + 0.5, self.y + 0.5, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
end
