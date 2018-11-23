mines = {}

function mines.enter(x)
    mines.x = x

    if not mines[x] then mines[x] = mines.generate() end
    mines[x]:eachEntity(function (ent)
        if ent.supertype == 'player' then mines[x]:despawn(ent) end
    end)
    mines[x]:spawn(currentmap.player)
    mines[x].player = currentmap.player
    mines[x].player.map = mines[x]
    mines[x].player.pos:set(12, -20)
    mines[x].player.vel:set(0, 1)

    currentmap = mines[x]
end

function mines.generate(x)
    local map = Map:new({
        mine = {
            x = x
        }
    }, 12, 60)
    map:each(1, function (x, y, tile)
        tile.id = 19
    end)
    map:setArea(1, 1, 2, 1, 1, 3)
    map:setArea(1, 1, 3, 2, 2, 2)

    map:newlayer(2)
    map:each(2, function (x, y, tile)
        if map:get(1, x, y).id ~= 1 then
            if y > 0 and chance(0.1) then tile.id = 65 end
            if y > 12 then
                if chance(0.03) then tile.id = 66 end
                if chance(0.03) then tile.id = 67 end
                if y > 24 then
                    if chance(0.025) then tile.id = 68 end
                    if y > 36 then
                        if chance(0.01) then tile.id = 69 end
                        if chance(0.01) then tile.id = 70 end
                    end
                end
            end
        end
    end)

    maps.autoprocess(map)
    return map
end
