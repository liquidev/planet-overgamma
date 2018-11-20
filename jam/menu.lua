HMenu = {}
HMenu.__index = HMenu

function HMenu:new(o)
    local o = o or {
        sprites = 'menu-default',
        elements = {}
    }
    setmetatable(o, self)
    self = o

    return self
end

function HMenu:draw()

end

return {
    HMenu
}
