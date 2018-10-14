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
    return self.instance.solids[y][x]
end

function Map:setSolid(solid, x, y)
    self.instance.solids[y][x] = solid
end

function Map:each(layer, f)
    local tiles = self.instance.layers[layer]

    for y = 1, self.height do
        for x = 1, self.width do
            f(x - 1, y - 1, tiles[y][x])
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
            f(x, y, self.solids[y][x])
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
        tiles = {},
        entities = {}
    }
end

function Map:begin()
    self:reset()

    self.instance = {}

    self.instance.layers = deepcopy(self.layers)
    self.instance.solids = deepcopy(self.solids)
    self.instance.entities = {}
    for _, ent in pairs(self.entities) do
        printtable(ent)
    end

    self:updateTiles()
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
    -- for _, tile in pairs(self.instance.tiles) do
    --     self._spritebatch:add(
    --         self.tilesetData.quads[tile.id],
    --         tile.x * Map.tilesize[1], tile.y * Map.tilesize[2])
    -- end
    self:eachLayer(function (layer, x, y, tile)
        self._spritebatch:add(
                self.tilesetData.quads[tile.id],
                (x) * self.tilesize[1], (y) * self.tilesize[2])
    end)
end

--[[
    LJMAP format version 1

    'LJMAP' [v]                             v - version
    [tiles     ]
       [i]                                  i - id; f - flags
       ...
    [entities  ]
       [x         ][y         ][classname )
       ...
    [options   ]
       [0][name)[v]                         v - value           -- boolean
       [1][name)[value                 ]                        -- number
       [2][name)[value )                                        -- string
       ...
]]
function Map:serialize()
    buf = StringBuffer:new('LJMAP')
    local function pack(fmt, ...)
        local arg = {...}
        buf:append(struct.pack(fmt, unpack(arg)))
    end

    --- version information
    pack('B', Map.version)

    --- metadata
    pack('HH', self.width, self.height)

    for i = 0, self.height do
        for i = 0, self.width do

        end
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
        ver = read('B')

        --- size
        map.width, map.height = read('HH')

        if ver == Map.version then
            -- --- tiles
            -- ntiles = read('I')
            -- for i = 0, ntiles - 1 do
            --     x, y, id, flags = read('HHBB')
            --     flags = numbertobits(flags)
            --     solid = flags[1] == 0 and true or false
            --     table.insert(map.tiles, {
            --         x = x, y = y,
            --         id = id,
            --         solid = solid
            --     })
            -- end
            --
            -- --- entities
            -- nent = read('I')
            -- for i = 0, nent - 1 do
            --     x, y, classname = read('ffs')
            --     E = Map.entityset[classname]
            --     table.insert(map.objects, {
            --         class = E,
            --         classname = classname,
            --         x = x, y = y
            --     })
            -- end
            --
            -- --- options
            -- nopt = read('I')
            -- for i = 0, nopt - 1 do
            --     t, key = read('Bs')
            --     val = nil
            --     if t == 0 then
            --         val = read('B')
            --     elseif t == 1 then
            --         val = read('d')
            --     elseif t == 2 then
            --         val = read('s')
            --     end
            --     map.options[key] = val
            -- end

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
    -- load the file
    if filename then
        data = love.filesystem.read('data/maps/'..filename)

        if data then
            -- options first
            for o in data:gmatch('%b[]') do
                assign = o:sub(2, -2)
                assign:gsub('([bnxs])%s+(%a+)%s*=%s*(.*)', function (type, name, tval)
                    val = nil
                    if type == 'b' then
                        val = (tval == 'true') and false or true
                    elseif type == 'n' then
                        val = tonumber(tval, 10)
                    elseif type == 'x' then
                        val = tonumber(tval, 16)
                    elseif type == 's' then
                        val = tval
                    end
                    self.options[name] = val
                    data = data:gsub(o:gsub('([^%w])', '%%%1'), '')
                end)
            end

            -- then the blocks and entities
            y = 0
            for ln in lines(data) do
                x = 0
                for c in ln:gmatch('.') do
                    id = string.find(Map.tileset, c, 1, true)
                    if id and id > 1 then
                        solid = false
                        if string.find(Map.solids, c, 1, true) then solid = true end
                        table.insert(self.tiles, {
                            id = id,
                            x = x, y = y,
                            sx = x * Map.tilesize[1], sy = y * Map.tilesize[2],
                            solid = solid
                        })
                    else
                        E = Map.entityset[c]
                        if E then
                            table.insert(self.objects, {
                                class = E[1],
                                classname = c,
                                x = x * Map.tilesize[1] + Map.tilesize[1] / 2,
                                y = y * Map.tilesize[2] + Map.tilesize[2] / 2
                            })
                            table.insert(self.tiles, {
                                id = string.find(Map.tileset, E[2], 1, true),
                                x = x,
                                y = y,
                                solid = false
                            })
                        end
                    end
                    x = x + 1
                end
                y = y + 1
            end

            self.tilesetData = jam.assets.tilesets[self.options.tileset or 'main']
            self.tilesetImg = self.tilesetData.image
            self._spritebatch = love.graphics.newSpriteBatch(self.tilesetImg, #self.tiles)
            self:begin()
            self:updateTiles()
        end
    end
end
