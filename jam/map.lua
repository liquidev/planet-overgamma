require 'jam/struct'
require 'jam/utils'
require 'jam/entity'

jam.maps = {}

Map = {}
Map.__index = Map

Map.version = 1

Map.tilesize = { 8, 8 }
Map.entityset = {} -- the entity set must be defined by the engine user

function Map:new(o, width, height, preload)
    o = o or {}
    setmetatable(o, self)
    self = o

    if preload == nil then preload = true end

    self.width = width or 16
    self.height = height or 16

    self.layers = { table2D(self.width, self.height, { id = 1 }) }
    self.solids = table2D(self.width, self.height, false)
    self.entities = {}
    self.options = {}

    self.scroll = Vector:new()

    if preload then
        self.tilesetData = jam.assets.tilesets[self.options.tileset or 'main']
        self.tilesetImg = self.tilesetData.image
        self._spritebatch = love.graphics.newSpriteBatch(self.tilesetImg, 1024)
        self:begin()
    end

    table.insert(jam.maps, self)

    return self
end

function Map:newlayer(layer)
    self.instance.layers[layer] = table2D(self.width, self.height, { id = 1 })
end

function Map:get(layer, x, y)
    if x > 0 and x <= self.width
    and y > 0 and y <= self.height then
        return self.instance.layers[layer][y][x]
    else
        return { id = 1 }
    end
end

function Map:set(id, layer, x, y)
    if x > 0 and x <= self.width
    and y > 0 and y <= self.height then
        if not self.instance.layers[layer] then
            self:newlayer(layer)
        end
        self.instance.layers[layer][y][x].id = id
    end
end

function Map:setArea(id, layer, x, y, w, h)
    for i = y, y + (h - 1) do
        for j = x, x + (w - 1) do
            self:set(id, layer, j, i)
        end
    end
end

function Map:getSolid(x, y)
    if x >= 0 and x < self.width - 1
    and y >= 0 and y < self.height - 1 then
        return self.instance.solids[y + 1][x + 1]
    else
        return false
    end
end

function Map:setSolid(solid, x, y)
    if x > 0 and x <= self.width
    and y > 0 and y <= self.height then
        self.instance.solids[y][x] = solid
    end
end

function Map:each(layer, f)
    local tiles = self.instance.layers[layer]

    for y = 1, self.height do
        for x = 1, self.width do
            f(x, y, tiles[y][x])
        end
    end
end

function Map:eachLayer(f)
    for i = 1, #self.instance.layers do
        self:each(i, function (...)
            f(i, unpack({...}))
        end)
    end
end

function Map:eachSolid(f)
    for y = 1, self.height do
        for x = 1, self.width do
            if self.instance.solids[y][x] then f({ x = x - 1, y = y - 1 }) end
        end
    end
end

function Map:spawn(entity)
    table.insert(self.instance.entities, entity)
end

function Map:despawn(entity)
    local i = table.find(self.instance.entities, entity)
    table.remove(self.instance.entities, i)
end

function Map:eachEntity(f)
    for _, entity in pairs(self.instance.entities) do
        f(entity)
    end
end

function Map:reset()
    self.instance = {
        layers = {},
        entities = {},
        solids = {}
    }
end

function Map:begin()
    self:reset()

    self.instance = {}

    self.instance.layers = deepcopy(self.layers)
    self.instance.solids = deepcopy(self.solids)
    self.instance.entities = {}
    for _, ent in pairs(self.entities) do
        local inst = ent.class:new(nil, ent.x, ent.y, self)
        table.insert(self.instance.entities, inst)
    end

    self:updateTiles()
end

function Map:store()
    self.layers = deepcopy(self.instance.layers)
    self.solids = deepcopy(self.instance.solids)
    self.entities = {}
    for _, inst in pairs(self.instance.entities) do
        local _, class = table.find(Map.entityset, inst.__index)
        local ent = {
            class = class,
            x = inst.pos.x, y = inst.pos.y
        }
        table.insert(self.entities, ent)
    end
end

-- tick runs even if the map isn't the active map
function Map:tick(dt)
    for i, e in pairs(self.instance.entities) do
        e:tick(dt)
        if e.remove then
            if e.death then e:death() end
            table.remove(self.instance.entities, i)
        end
    end
end

function Map:run(dt)
    for i, e in pairs(self.instance.entities) do
        e:update(dt)
    end
end

function Map:draw()
    jam.activemap = self
    love.graphics.push()

    love.graphics.translate(-self.scroll.x, -self.scroll.y)
    love.graphics.draw(self._spritebatch)
    for _, e in pairs(self.instance.entities) do
        e:draw()
    end

    love.graphics.pop()
end

function Map:updateTiles()
    self._spritebatch:clear()
    self:eachLayer(function (layer, x, y, tile)
        self._spritebatch:add(
                self.tilesetData.quads[tile.id],
                (x - 1) * self.tilesize[1], (y - 1) * self.tilesize[2])
    end)
end

function Map:autotile(layer, tilesets, bits)
    bits = (bits or 'rldu'):reverse()
    local uv, dv, lv, rv =
        2 ^ (bits:find('u') - 1),
        2 ^ (bits:find('d') - 1),
        2 ^ (bits:find('l') - 1),
        2 ^ (bits:find('r') - 1)

    for _, index in pairs(tilesets) do
        self:each(layer, function (x, y, tile)
            if tile.id >= index and tile.id < index + 16 then
                local u, d, l, r =
                    self:get(layer, x, y - 1).id,
                    self:get(layer, x, y + 1).id,
                    self:get(layer, x - 1, y).id,
                    self:get(layer, x + 1, y).id
                local id = index
                if u >= index and u < index + 16 then id = id + uv end
                if d >= index and d < index + 16 then id = id + dv end
                if l >= index and l < index + 16 then id = id + lv end
                if r >= index and r < index + 16 then id = id + rv end
                self:set(id, layer, x, y)
            end
        end)
    end
    self:updateTiles()
end

function Map:autosolid(layer, tiles, reset)
    if reset == nil then reset = false end

    if reset then
        for y = 1, self.height do
            for x = 1, self.width do
                self.instance.solids[y][x] = false
            end
        end
    end

    self:each(1, function (x, y, tile)
        self.instance.solids[y][x] = self.instance.solids[y][x] or table.has(tiles, tile.id)
    end)

    local osolids = deepcopy(self.instance.solids)
    for y = 2, self.height - 1 do
        for x = 2, self.width - 1 do
            if osolids[y][x - 1] and osolids[y][x + 1]
            and osolids[y - 1][x] and osolids[y + 1][x] then
                self.instance.solids[y][x] = false
            end
        end
    end
end

--[[
    LJMAP format version 1
    FIXME: this section needs updating to describe the new format

    'LJMAP' [v]                             v - version
    [w   ][h   ]                            w - width, h - height
    [#layers   ]
       [i] ...                                                      -- layer 1
       [i] ...                                                      -- layer 2
       [i] ...                                                      -- layer 3
       ...
       [i] ...                                                      -- layer n
    [#entities ]
       [x         ][y         ][classname )
       ...
    [#options  ]
       [0][name)[v]                         v - value               -- boolean
       [1][name)[value                 ]                            -- number
       [2][name)[value )                                            -- string
       ...
]]
function Map:serialize()
    local buf = StringBuffer:new('LJMAP')
    local function pack(fmt, ...)
        local arg = {...}
        buf:append(struct.pack(fmt, unpack(arg)))
    end

    --- version information
    pack('B', Map.version)

    --- metadata
    pack('HH', self.width, self.height)

    --- layers
    pack('I', #self.layers)
    for l = 1, #self.layers do
        for y = 1, self.height do
            for x = 1, self.width do
                pack('B', self:get(l, x, y).id - 1)
            end
        end
    end

    --- solids
    for y = 1, self.height do
        for x = 1, self.width do
            pack('B', self:getSolid(x - 1, y - 1) and 1 or 0)
        end
    end

    --- entities
    self:store()
    pack('I', #self.entities)
    for _, ent in pairs(self.entities) do
        local id = table.find(self.entityset, ent.class)
        pack('ffH', ent.x, ent.y, id)
    end

    return buf:collect()
end

function Map:savefile(filename)
    out = assert(io.open(filename, 'wb'))
    out:write(self:serialize())
    assert(out:close())
end

function Map.deserialize(data)
    local pos = 1

    local function read(fmt)
        vars = { struct.unpack(fmt, data, pos) }
        pos = vars[1]
        table.remove(vars, 1)
        return unpack(vars)
    end

    if data:startswith('LJMAP') then
        data = data:sub(6)

        --- version information
        local ver = read('B')

        --- size
        local mapwidth, mapheight = read('HH')
        local map = Map:new({}, mapwidth, mapheight)

        if ver == Map.version then
            --- layers
            local nlr = read('I')
            map.layers = {}
            for l = 1, nlr do
                map.layers[l] = {}
                for y = 1, map.height do
                    map.layers[l][y] = {}
                    for x = 1, map.width do
                        local id = read('B') + 1
                        map.layers[l][y][x] = { id = id }
                    end
                end
            end

            --- solids
            for y = 1, map.height do
                for x = 1, map.width do
                    map.solids[y][x] = tern(read('B') == 1, true, false)
                end
            end

            --- entities
            local nent = read('I')
            for i = 1, nent do
                local x, y, id = read('ffH')
                local class = Map.entityset[id]
                table.insert(map.entities, {
                    class = class,
                    x = x, y = y
                })
            end

            return map
        else
            error('lj: tried to deserialize unsupported map version, try using legacy_deserialize for this map instead')
        end
    else
        error('lj: tried to deserialize invalid ljm data')
    end
end



-- This is the previous version's deserialization method, DO NOT use it in production code!
-- Why not use it? It doesn't have a reverse counterpart, so you can't save maps with it, only load them!
-- Also the format is unsupported. Use this function only for conversion purposes!
function Map:legacy_deserialize(filename)
    error('lj: text lovejam maps are not supported. recreate your maps with the editor!')
end
