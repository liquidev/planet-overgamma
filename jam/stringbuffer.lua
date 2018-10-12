StringBuffer = {}
StringBuffer.__index = StringBuffer

function StringBuffer:new(str)
    o = {}
    setmetatable(o, self)
    self = o

    str = str or ''

    self.buffer = { str }

    return self
end

function StringBuffer:append(str)
    table.insert(self.buffer, str)

    return self
end

function StringBuffer:collect()
    return table.concat(self.buffer)
end
