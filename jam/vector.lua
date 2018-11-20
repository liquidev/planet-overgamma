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

function Vector:point(x, y)
    return {
        x = x, y = y
    }
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

function Vector:limit(minx, maxx, miny, maxy)
    if self.x < minx then self.x = minx end
    if self.y < miny then self.y = miny end
    if self.x > maxx then self.x = maxx end
    if self.y > maxy then self.y = maxy end
    return self
end

function Vector:decel(x, y, precision)
    if precision == nil then precision = 0.02 end

    if self.x < 0 then self.x = self.x + x end
    if self.x > 0 then self.x = self.x - x end
    if self.y < 0 then self.y = self.y + y end
    if self.y > 0 then self.y = self.y - y end

    if  self.x > -precision
    and self.x < precision then
        self.x = 0
    end

    if  self.y > -precision
    and self.y < precision then
        self.y = 0
    end

    return self
end

function Vector:copy()
    return Vector:new(self.x, self.y)
end

function Vector:tostr()
    return string.format('(%.4f, %.4f)', self.x, self.y)
end

return Vector
