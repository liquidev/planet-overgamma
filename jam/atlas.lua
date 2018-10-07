Atlas = {}
Atlas.__index = Atlas

function Atlas:new(image, tw, th)
    local o = {}
    setmetatable(o, self)
    self = o

    self.image = image
    self.quads = {}
    self.spritesize = { tw, th }
    nh = image:getWidth() / tw
    nv = image:getHeight() / th
    n = nh * nv
    for i = 0, n - 1 do
        x = (i % nh) * tw
        y = math.floor(i * tw / image:getWidth()) * th
        quad = love.graphics.newQuad(x, y, tw, th, image:getDimensions())
        table.insert(self.quads, quad)
    end
    return self
end

function Atlas:draw(index, x, y)
    love.graphics.draw(self.image, self.quads[index], x, y)
end

return Atlas
