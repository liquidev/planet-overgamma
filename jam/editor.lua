require 'jam/map'

jam.states.__jam_editor__ = {}

do
    map = nil
    mode = 'map-edit'
    sel = Vector:new()
    tileset = 'main'
    tileid = 2

    function jam.states.__jam_editor__.begin()
        love.window.setTitle('lovejam map editor')
        map = Map:new({})
    end

    function jam.states.__jam_editor__.draw()
        map:draw()
        jam.activemap = nil

        love.graphics.setColor(1, 1, 1, 0.25)
        jam.assets.tilesets['main']:draw(tileid, sel.x * Map.tilesize[1], sel.y * Map.tilesize[1])
        love.graphics.setColor(1, 1, 1, 1)
    end

    function jam.states.__jam_editor__.update(dt)
        sel:set(math.floor(jam.mouse.x / Map.tilesize[1]), math.floor(jam.mouse.y / Map.tilesize[2]))
    end

    local function _mapset()
        if love.mouse.isDown(1) then
            map:set(tileid, sel.x, sel.y)
            map:updateTiles()
        end
    end

    function jam.states.__jam_editor__.mousepressed()
        _mapset()
    end

    function jam.states.__jam_editor__.mousemoved()
        _mapset()
    end

    function jam.states.__jam_editor__.wheelmoved(_, y)
        if y > 0 then
            if tileid > 1 then tileid = tileid - 1 end
        elseif y < 0 then
            if tileid < 256 then tileid = tileid + 1 end
        end
    end
end
