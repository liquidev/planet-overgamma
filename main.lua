--[[
    Planet Overgamma+lovejam alpha (c) iLiquid 2018
    a platformer/survival hybrid -- read more at https://github.com/liquid600pgm/planet-overgamma
    licensed under the MIT license
]]

require 'jam'
require 'jam/platformer'

require 'maps'
require 'items'
require 'mines'

require 'player'

Map.entityset = {
    Player,
    Item
}

currentmap = nil

function jam.load(args)
    love.graphics.setFont(jam.asset('font', 'main'))
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
