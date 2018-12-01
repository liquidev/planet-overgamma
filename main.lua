--[[
    Planet Overgamma+lovejam alpha (c) iLiquid 2018
    a platformer/survival hybrid -- read more at https://github.com/liquid600pgm/planet-overgamma
    licensed under the MIT license
]]

require 'jam'
require 'jam.platformer'

require 'inventory'
require 'maps'
require 'items'
require 'mines'
require 'blocks'

require 'player'

Map.entityset = {
    Player,
    Item
}

currentmap = nil

function jam.load(args)
    love.graphics.setFont(jam.asset('font', 'main'))
    jam.setstate('game')
end

jam.states.title = {}
local tlock = false

function jam.states.title.begin()
end

function jam.states.title.draw()
    jam.asset('map', 'planet'):draw()
    jam.asset('map', 'planet'):reset()
    jam.noupdate()

    jam.asset('map', 'planet').scroll:set(
        math.sin(love.timer.getTime()) * 16 + 16,
        10 * 8)

    jam.asset('sprite', 'logo'):draw(1, 48 - 83 / 2, 24)

    love.graphics.setColor(Color.rgb(0, 0, 0))
    love.graphics.printf('Click to begin', 0, 63, 96, 'center')
    love.graphics.printf('Click to begin', 0, 65, 96, 'center')
    love.graphics.printf('Click to begin', -1, 64, 96, 'center')
    love.graphics.printf('Click to begin', 1, 64, 96, 'center')
    love.graphics.setColor(Color.rgb(255, 255, 255))
    love.graphics.printf('Click to begin', 0, 64, 96, 'center')
end

function jam.states.title.update(dt)

end

function jam.states.title.mousepressed()
    if not tlock then
        tlock = true
        jam.gfx.wipe('radial_wipe', 0.5, true, { smoothness = 0.1, invert = true }, function ()
            blankwait(0.5, 'game', function ()
                currentmap = jam.asset('map', 'planet')
                currentmap:begin()
            end)
        end)
    end
end

function jam.states.game.begin()
    if currentmap == nil then
        currentmap = jam.asset('map', 'planet')
    end
    maps.autoprocess(currentmap)
    jam.gfx.wipe('radial_wipe', 0.5, false, { smoothness = 0.1, invert = true })
end

function jam.states.game.draw()
    currentmap:draw()
end

function jam.states.game.update(dt)
    if currentmap.mine then
        mines.update_lighting()
    end
    currentmap:eachLayer(function (layer, x, y, tile)
        if tile.id == 18 then
            if currentmap:get(layer, x, y + 1).id == 1 then
                tile.id = 1
                maps.autoprocess(currentmap)
            end
        end
    end)
end

jam.states.wait = {
    endtime = 0,
    duration = 0,
    go_to = 'game',
    callback = function () end,

    begin = function ()
        jam.states.wait.endtime = love.timer.getTime() + jam.states.wait.duration
    end,
    draw = function () end,
    update = function ()
        if love.timer.getTime() > jam.states.wait.endtime then
            if jam.states.wait.callback then jam.states.wait.callback() end
            jam.setstate(jam.states.wait.go_to)
        end
    end
}

function blankwait(duration, go_to, callback)
    jam.states.wait.duration = duration
    jam.states.wait.go_to = go_to
    jam.states.wait.callback = callback
    jam.setstate('wait')
end
