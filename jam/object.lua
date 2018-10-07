Object = {}
Object.__index = Object

function Object:extend(o)
    o = o or {}
    obj = {}

    for k, v in pairs(self) do
        obj[k] = v
    end

    for k, v in pairs(o) do
        obj[k] = v
    end

    return obj
end
