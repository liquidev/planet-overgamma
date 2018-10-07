require 'jam/utils'
require 'jam/entity'

Map = {
    tilesize = { 8, 8 },
    tileset = ' 0123456789abcdefghijklmnopqrstuvwxyz',
    solids = '0123456789',
    entityset = {} -- the entityset must be defined by the engine user
}
Map.__index = Map

function Map:new(filename)
    local o = {}
    setmetatable(o, self)
    self = o

    self.tiles = {}
    self.options = {}
    self.objects = {}

    self.instance = {
        tiles = {},
        entities = {}
    }

    -- load the file
    data, _ = love.filesystem.read('data/maps/'..filename)

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
                            x = x * Map.tilesize[1] + Map.tilesize[1] / 2,
                            y = y * Map.tilesize[2] + Map.tilesize[2] / 2
                        })
                        table.insert(self.tiles, {
                            id = string.find(Map.tileset, E[2], 1, true),
                            x = x,
                            y = y
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

    return self
end

function Map:get(x, y)
    found = nil
    for _, tile in pairs(self.instance.tiles) do
        if tile.x == x and tile.y == y then
            found = tile
            break
        end
    end
    return found
end

function Map:getSolid(x, y)
    found = nil
    for _, tile in pairs(self.instance.tiles) do
        if tile.solid and tile.x == x and tile.y == y then
            found = tile
            break
        end
    end
    return found
end

function Map:each(f)
    for _, tile in pairs(self.instance.tiles) do
        f(tile)
    end
end

function Map:eachSolid(f)
    self:each(function (tile)
        if tile.solid then f(tile) end
    end)
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

    for _, tile in pairs(self.tiles) do
        table.insert(self.instance.tiles, deepcopy(tile))
    end

    for _, obj in pairs(self.objects) do
        i = obj.class:new(nil, obj.x, obj.y, self)
        table.insert(self.instance.entities, i)
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
    for _, tile in pairs(self.instance.tiles) do
        self._spritebatch:add(
            self.tilesetData.quads[tile.id],
            tile.x * self.tilesize[1], tile.y * self.tilesize[2])
    end
end
