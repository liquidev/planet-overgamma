require 'jam/map'

jam.states.__jam_editor__ = {
    map = nil
}

do
    local map = nil
    local mode = 'tile-edit'
    local play = false
    local sel = Vector:new()
    local tileset = 'main'

    local tileid = 2
    local entityid = 1
    local selent = nil

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
        if not play then jam.noupdate() end

        if mode == 'tile-edit' then
            love.graphics.setColor(1, 1, 1, 0.25)
            jam.assets.tilesets['main']:draw(tileid, sel.x * Map.tilesize[1], sel.y * Map.tilesize[1])
        elseif mode == 'solid-edit' then
            love.graphics.setColor(1, 1, 1, 0.5)
            map:eachSolid(function (tile)
                love.graphics.rectangle('fill',
                        (tile.x ) * Map.tilesize[1] + 0.5, (tile.y) * Map.tilesize[1] + 0.5,
                        Map.tilesize[1], Map.tilesize[2])
            end)
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.rectangle('line',
                    sel.x * Map.tilesize[1] + 0.5, sel.y * Map.tilesize[2] + 0.5,
                    Map.tilesize[1] - 1, Map.tilesize[2] - 1)
        elseif mode == 'entity-edit' then
            map:eachEntity(function (ent)
                if ent == selent then
                    if not love.keyboard.isScancodeDown('lshift') then love.graphics.setColor(1, 0, 1, 1)
                    else love.graphics.setColor(0, 1, 1, 1) end
                else love.graphics.setColor(1, 0, 0, 1) end
                love.graphics.rectangle('line',
                        ent.pos.x - ent.hitboxsize[1] / 2 + 0.5,
                        ent.pos.y - ent.hitboxsize[2] / 2 + 0.5,
                        ent.hitboxsize[1] - 1,
                        ent.hitboxsize[2] - 1)
            end)
        end

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

        if selent then
            if not love.keyboard.isScancodeDown('lshift') then selent.pos:set(jam.mouse.x, jam.mouse.y)
            else selent.pos:set(
                    math.floor(jam.mouse.x / Map.tilesize[1]) * Map.tilesize[1] + Map.tilesize[1] / 2,
                    math.floor(jam.mouse.y / Map.tilesize[2]) * Map.tilesize[2] + Map.tilesize[2] / 2) end
        end
    end

    local function _mapset()
        if mode == 'tile-edit' then
            if love.mouse.isDown(1) then
                map:set(tileid, 1, sel.x + 1, sel.y + 1)
                map:updateTiles()
            elseif love.mouse.isDown(2) then
                map:set(1, 1, sel.x + 1, sel.y + 1)
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
                            ent.pos.x - ent.hitboxsize[1] / 2 + 0.5,
                            ent.pos.y - ent.hitboxsize[2] / 2 + 0.5,
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
                                    sel.x * Map.tilesize[1] + Map.tilesize[1] / 2, sel.y * Map.tilesize[2] + Map.tilesize[2] / 2,
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

    function jam.states.__jam_editor__.mousemoved()
        if not play then _mapset() end
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

    function jam.states.__jam_editor__.keypressed(key)
        if     key == '1' then mode = 'tile-edit'; msg('mode: tiles')
        elseif key == '2' then mode = 'solid-edit'; msg('mode: solids')
        elseif key == '3' then mode = 'entity-edit'; msg('mode: entities')
        elseif key == 'tab' then
            play = not play
            msg('play mode '..tern(play, 'on', 'off'))
            if play then
                map:store()
            end
            map:begin()
        end

        if not play then
            if key == 's' then
                map:savefile('data/maps/'..jam.states.__jam_editor__.map..'.ljm')
                msg('saved')
            end
        end
    end
end
