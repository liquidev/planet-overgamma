require 'jam/map'

jam.states.__jam_editor__ = {
    map = nil
}

do
    local map = nil
    local mode = 'map-edit'
    local sel = Vector:new()
    local tileset = 'main'
    local tileid = 2

    local message = ''
    local messageexpire = love.timer:getTime()
    local messagetext = nil

    function msg(txt, time)
        time = time or 1.5
        message = txt
        messageexpire = love.timer:getTime() + time
        print('lj-edit: '..txt)
    end

    function jam.states.__jam_editor__.begin()
        love.window.setTitle('lovejam map editor')
        if jam.states.__jam_editor__.map and jam.assets.maps[jam.states.__jam_editor__.map] then
            map = jam.assets.maps[jam.states.__jam_editor__.map]
        else
            map = Map:new({})
        end
        messagetext = love.graphics.newText(jam.assets.fonts['main'])
        msg('editing: '..(jam.states.__jam_editor__.map or '(new map)'))
    end

    function jam.states.__jam_editor__.draw()
        map:draw()
        jam.activemap = nil

        love.graphics.setColor(1, 1, 1, 0.25)
        jam.assets.tilesets['main']:draw(tileid, sel.x * Map.tilesize[1], sel.y * Map.tilesize[1])
        love.graphics.setColor(1, 1, 1, 1)

        messagetext:set(message)
        if love.timer.getTime() < messageexpire then
            love.graphics.setColor(0, 0, 0, 0.8)
            love.graphics.rectangle('fill', 0, 0, messagetext:getDimensions())
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(messagetext)
        end
    end

    function jam.states.__jam_editor__.update(dt)
        sel:set(math.floor(jam.mouse.x / Map.tilesize[1]), math.floor(jam.mouse.y / Map.tilesize[2]))
    end

    local function _mapset()
        if love.mouse.isDown(1) then
            map:set(tileid, 1, sel.x + 1, sel.y + 1)
            map:updateTiles()
        elseif love.mouse.isDown(2) then
            map:set(1, 1, sel.x + 1, sel.y + 1)
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
        msg('tile: '..tileid, 0.5)
    end

    function jam.states.__jam_editor__.keypressed(key)
        if mode == 'map-edit' then
            if key == 's' then
                msg('saved')
            end
        end
    end
end
