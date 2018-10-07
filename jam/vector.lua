Vector = {}
Vector.__index = Vector

function Vector:new(x, y)
    local o = {}
    setmetatable(o, self)
    self = o

    x = x or 0
    y = y or 0

    self.x = x
    self.y = y

    return self
end

function Vector:set(x, y)
    self.x = x
    self.y = y
end

function Vector:add(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
    return self
end

function Vector:sub(other)
    self.x = self.x - other.x
    self.y = self.y - other.y
    return self
end

function Vector:mul(x, y)
    if not y then y = x end
    self.x = self.x * x
    self.y = self.y * y
    return self
end

function Vector:div(x, y)
    if not y then y = x end
    self.x = self.x / x
    self.y = self.y / x
    return self
end

function Vector:copy()
    return Vector:new(self.x, self.y)
end

return Vector
