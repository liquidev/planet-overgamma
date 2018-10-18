require 'jam/struct'
require 'jam/utils'
require 'jam/entity'

Map = {}
Map.__index = Map

Map.version = 1

Map.tilesize = { 8, 8 }
Map.tileset = ' 0123456789abcdefghijklmnopqrstuvwxyz'
Map.solids = '0123456789'
Map.entityset = {} -- the entityset must be defined by the engine user

function Map:new(o, preload)
    o = o or {}
    setmetatable(o, self)
    self = o

    if preload == nil then preload = true end

    self.width = 16
    self.height = 16

    self.layers = { table2D(self.width, self.height, { id = 1 }) }
    self.solids = table2D(self.width, self.height, false)
    self.entities = {}
    self.options = {}

    if preload then
        self.tilesetData = jam.assets.tilesets[self.options.tileset or 'main']
        self.tilesetImg = self.tilesetData.image
        self._spritebatch = love.graphics.newSpriteBatch(self.tilesetImg, 1024)
        self:begin()
    end

    return self
end

function Map:get(layer, x, y)
    return self.instance.layers[layer][y][x]
end

function Map:set(id, layer, x, y)
    self.instance.layers[layer][y][x].id = id
end

function Map:getSolid(x, y)
    return self.instance.solids[y + 1][x + 1]
end

function Map:setSolid(solid, x, y)
    self.instance.solids[y][x] = solid
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
    for i = 1, #self.layers do
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

function Map:run(dt)
    for i, e in pairs(self.instance.entities) do
        e:update(dt)
        if e.remove then
            if e.death then e:death() end
            table.remove(self.instance.entities, i)
        end
    end
end

function Map:draw()
    jam.activemap = self
    love.graphics.draw(self._spritebatch)
    for _, e in pairs(self.instance.entities) do
        e:draw()
    end
end

function Map:updateTiles()
    self._spritebatch:clear()
    self:eachLayer(function (layer, x, y, tile)
        self._spritebatch:add(
                self.tilesetData.quads[tile.id],
                (x - 1) * self.tilesize[1], (y - 1) * self.tilesize[2])
    end)
end

--[[
    LJMAP format version 1

    'LJMAP' [v]                             v - version
    [w   ][h   ]                            w - width, h - height
    [layers    ]
       [i] ...                                                      -- layer 1
       [i] ...                                                      -- layer 2
       [i] ...                                                      -- layer 3
       ...
       [i] ...                                                      -- layer n
    [entities  ]
       [x         ][y         ][classname )
       ...
    [options   ]
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
    local map = Map:new({}, nil)
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
        map.width, map.height = read('HH')

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
