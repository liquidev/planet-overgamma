require 'jam/map'

jam.states.__jam_editor__ = {
    map = nil
}

do
    local map = nil
    local mode = 'tile-edit'
    local play = false
    local console = false
    local sel = Vector:new()
    local layer = 1
    local tileset = 'main'

    local tileid = 2
    local entityid = 1
    local selent = nil

    local scroll = Vector:new()

    local message = ''
    local messageexpire = love.timer:getTime()
    local messagetext = nil

    local cmd = ''
    local cmdtext = nil

    function msg(txt, time)
        time = time or 1.5
        message = txt
        messageexpire = love.timer:getTime() + time
        print('lj-edit: '..txt)
    end

    function jam.states.__jam_editor__.begin()
        love.window.setTitle('lovejam map editor')

        local mapname = jam.arg('%-M(.+)')
        if mapname then jam.states.__jam_editor__.map = mapname
        else jam.states.__jam_editor__.map = 'untitled' end

        if jam.states.__jam_editor__.map and jam.assets.maps[jam.states.__jam_editor__.map] then
            map = jam.assets.maps[jam.states.__jam_editor__.map]
        else
            local mapwidth, mapheight = jam.arg('%-s(%d+),(%d+)')
            map = Map:new(nil, tonumber(mapwidth or '16'), tonumber(mapheight or '16'))
        end
        messagetext = love.graphics.newText(jam.assets.fonts['main'])
        cmdtext = love.graphics.newText(jam.assets.fonts['main'])
        msg('editing: '..(jam.states.__jam_editor__.map or '!! error !!'))
    end

    function jam.states.__jam_editor__.draw()
        if not play then
            love.graphics.rectangle('line',
                    -scroll.x, -scroll.y,
                    map.width * Map.tilesize[1], map.height * Map.tilesize[2])
        end

        map:draw()
        if not play then jam.noupdate() end

        if not play then
            if mode == 'tile-edit' then
                love.graphics.setColor(Color.rgba(255, 255, 255, 0.25))
                jam.assets.tilesets[tileset]:draw(
                    tileid,
                    sel.x * Map.tilesize[1] - scroll.x,
                    sel.y * Map.tilesize[1] - scroll.y)
            elseif mode == 'solid-edit' then
                love.graphics.setColor(Color.rgba(255, 255, 255, 0.5))
                map:eachSolid(function (tile)
                    love.graphics.rectangle('fill',
                            tile.x * Map.tilesize[1] + 0.5 - scroll.x, tile.y * Map.tilesize[1] + 0.5 - scroll.y,
                            Map.tilesize[1], Map.tilesize[2])
                end)
                love.graphics.setColor(Color.rgb(255, 0, 0))
                love.graphics.rectangle('line',
                        sel.x * Map.tilesize[1] - scroll.x, sel.y * Map.tilesize[2] - scroll.y,
                        Map.tilesize[1], Map.tilesize[2])
            elseif mode == 'entity-edit' then
                map:eachEntity(function (ent)
                    if ent == selent then
                        if not love.keyboard.isScancodeDown('lshift') then love.graphics.setColor(Color.rgb(255, 0, 255))
                        else love.graphics.setColor(Color.rgb(0, 255, 255)) end
                    else love.graphics.setColor(Color.rgb(255, 0, 0)) end
                    love.graphics.rectangle('line',
                            ent.pos.x - ent.hitboxsize[1] / 2 + 0.5 - scroll.x,
                            ent.pos.y - ent.hitboxsize[2] / 2 + 0.5 - scroll.y,
                            ent.hitboxsize[1] - 1,
                            ent.hitboxsize[2] - 1)
                end)
            end
        end

        love.graphics.setColor(Color.rgb(255, 255, 255))

        if love.timer.getTime() < messageexpire then
            messagetext:set(message)
            love.graphics.setColor(Color.rgba(0, 0, 0, 0.8))
            love.graphics.rectangle('fill', 0, 0, messagetext:getDimensions())
            love.graphics.setColor(Color.rgb(255, 255, 255))
            love.graphics.draw(messagetext)
        end
        if console then
            cmdtext:set('*'..cmd)
            love.graphics.setColor(Color.rgba(0, 0, 0, 0.8))
            love.graphics.rectangle('fill', 0, jam.cheight - ({cmdtext:getDimensions()})[2], cmdtext:getDimensions())
            love.graphics.setColor(Color.rgb(255, 255, 255))
            love.graphics.draw(cmdtext, 0, jam.cheight - ({cmdtext:getDimensions()})[2])
        end
    end

    function jam.states.__jam_editor__.update(dt)
        sel:set(math.floor(jam.mapmouse.x / Map.tilesize[1]), math.floor(jam.mapmouse.y / Map.tilesize[2]))

        if selent then
            if not love.keyboard.isScancodeDown('lshift') then selent.pos:set(jam.mapmouse.x, jam.mapmouse.y)
            else selent.pos:set(
                    math.floor(jam.mapmouse.x / Map.tilesize[1]) * Map.tilesize[1] + Map.tilesize[1] / 2,
                    math.floor(jam.mapmouse.y / Map.tilesize[2]) * Map.tilesize[2] + Map.tilesize[2] / 2) end
        end

        local key = love.keyboard.isScancodeDown
        if not play then
            if not console then
                local step = dt * 80
                if key('rctrl') then step = dt * 160 end

                if key('up') then scroll:add(Vector:point(0, -step)) end
                if key('down') then scroll:add(Vector:point(0, step)) end
                if key('left') then scroll:add(Vector:point(-step, 0)) end
                if key('right') then scroll:add(Vector:point(step, 0)) end

                if love.mouse.isDown(3) then
                    scroll:add(jam.pmouse:copy():sub(jam.mouse):mul(2))
                end
            end
        end

        if not play then map.scroll:set(scroll.x, scroll.y) end
    end

    local function _mapset()
        if mode == 'tile-edit' then
            if love.mouse.isDown(1) then
                map:set(tileid, layer, sel.x + 1, sel.y + 1)
                map:updateTiles()
            elseif love.mouse.isDown(2) then
                map:set(1, layer, sel.x + 1, sel.y + 1)
                map:updateTiles()
            end
        elseif mode == 'solid-edit' then
            if love.mouse.isDown(1) then
                map:setSolid(true, sel.x + 1, sel.y + 1)
            elseif love.mouse.isDown(2) then
                map:setSolid(false, sel.x + 1, sel.y + 1)
            end
        end
    end

    function jam.states.__jam_editor__.mousepressed()
        if not play then
            _mapset()
            if mode == 'entity-edit' then
                local picked = nil
                map:eachEntity(function (ent)
                    local hitbox = Hitbox:new(
                            ent.pos.x - ent.hitboxsize[1] / 2 + 0.5 - scroll.x,
                            ent.pos.y - ent.hitboxsize[2] / 2 + 0.5 - scroll.y,
                            ent.hitboxsize[1],
                            ent.hitboxsize[2])
                    if hitbox:has(jam.mouse) then
                        picked = ent
                    end
                end)
                if love.mouse.isDown(1) then
                    if not selent then
                        if not picked then
                            local E = map.entityset[entityid]
                            local instance = E:new(nil,
                                    sel.x * Map.tilesize[1] + Map.tilesize[1] / 2,
                                    sel.y * Map.tilesize[2] + Map.tilesize[2] / 2,
                                    map)
                            jam.spawn(instance)
                        else
                            selent = picked
                        end
                    else
                        selent = nil
                    end
                elseif love.mouse.isDown(2) then
                    if picked then
                        jam.despawn(picked)
                    end
                end
            end
        end
    end

    function jam.states.__jam_editor__.mousereleased()
    end

    function jam.states.__jam_editor__.mousemoved()
        if not play then
            _mapset()
        end
    end

    function jam.states.__jam_editor__.wheelmoved(_, y)
        if not play then
            if mode == 'tile-edit' then
                if y < 0 then
                    if tileid > 1 then tileid = tileid - 1 end
                elseif y > 0 then
                    if tileid < 256 then tileid = tileid + 1 end
                end
                msg('tile: '..tileid, 0.5)
            elseif mode == 'entity-edit' then
                if y < 0 then
                    if entityid > 1 then entityid = entityid - 1 end
                elseif y > 0 then
                    if entityid < #Map.entityset then entityid = entityid + 1 end
                end
                local E = Map.entityset[entityid]
                msg('entity: #'..entityid..' '..E.name or E.supertype, 0.5)
            end
        end
    end

    function jam.states.__jam_editor__.keypressed(key, scancode)
        if not console then
            if     key == '1' then mode = 'tile-edit'; msg('mode: tiles')
            elseif key == '2' then mode = 'solid-edit'; msg('mode: solids')
            elseif key == '3' then mode = 'entity-edit'; msg('mode: entities')
            elseif key == 'tab' then
                play = not play
                msg('play mode '..tern(play, 'on', 'off'))
                if play then
                    map:store()
                end
                map.scroll:set(0, 0)
                map:begin()
            end
        end

        if not play then
            if not console then
                if key == 's' then
                    map:savefile('data/maps/'..jam.states.__jam_editor__.map..'.ljm')
                    msg('saved')
                elseif scancode == '=' then
                    layer = layer + 1
                    msg('layer: '..layer)
                elseif scancode == '-' then
                    layer = layer - 1
                    msg('layer: '..layer)
                elseif key == 'return' then
                    console = true
                    cmd = ''
                    love.keyboard.setKeyRepeat(true)
                end
            else
                if key == 'backspace' then
                    cmd = cmd:sub(1, #cmd - 1)
                elseif key == 'return' then
                    print('lj-edit* '..cmd)
                    command(cmd)
                    console = false
                    love.keyboard.setKeyRepeat(false)
                end
            end
        end
    end

    function jam.states.__jam_editor__.textinput(key)
        cmd = cmd..key
    end

    local commands = {
        -- map commands
        ['at'] = function (_, tiles, bits) -- autotile
            local tilesets = {}
            for t in tiles:gmatch('%d+') do
                local ok, out = pcall(tonumber, t)
                if not ok then
                    msg(' ! something went wrong')
                    return
                end
                table.insert(tilesets, out)
            end
            map:autotile(layer, tilesets, bits)
        end,
        ['as'] = function (_, layer_, tiles_, reset_) -- autosolid
            reset = reset_ or 'f'

            if not (layer_ and tiles_) then
                msg(' ! [1] and [2] are\n   required')
                return
            end

            local ok, layer = pcall(tonumber, layer_)
            if type(layer) ~= 'number' then
                msg(' ! [1] must be a number')
                return
            end

            if not map.instance.layers[layer] then
                msg(" ! layer doesn't exist")
                return
            end

            local tiles = {}
            tiles_ = tiles_:gsub('(%d+)%-(%d+)', function (start, stop)
                start, stop = tonumber(start), tonumber(stop)
                local range = { range(start, stop) }
                for _, v in pairs(range) do table.insert(tiles, v) end
                return ''
            end)
            tiles_ = tiles_:gsub('(%d+)', function (num)
                table.insert(tiles, tonumber(num))
            end)

            if reset == 't' then reset = true
            elseif reset == 'f' then reset = false
            else msg(' ! [3] must be a boolean') return end

            map:autosolid(layer, tiles, reset)
        end,

        -- debug commands
        ['-d-tc'] = function () -- -debug-test-commands
            msg('it works!')
        end,
        ['-d-ta'] = function (_, arg) -- -debug-test-arguments
            if arg then msg('arg: '..arg)
            else msg('no argument provided') end
        end
    }

    function command(cmd)
        local args = {}
        for a in cmd:gmatch('[a-z0-9.,;+-]+') do
            table.insert(args, a)
        end
        local found = false
        for c, f in pairs(commands) do
            if args[1] == c then f(unpack(args)); found = true; break end
        end
        if not found then
            msg(' ! invalid command')
        end
    end
end
