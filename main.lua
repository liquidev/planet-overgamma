--[[
    Planet Overgamma+lovejam alpha (c) iLiquid 2018
    a platformer/survival hybrid -- read more at https://github.com/liquid600pgm/planet-overgamma
    licensed under the MIT license
]]

require 'jam'
require 'jam/platformer'

require 'items'
require 'player'

Map.entityset = {
    Player,
    Item
}

function jam.load(args)
    love.graphics.setFont(jam.asset('font', 'main'))
end

function jam.states.game.begin()
    print('begin')
    jam.gfx.wipe('radial_wipe', 0.5, false, { smoothness = 0.05, invert = true }, function ()
    end)
end

function jam.states.game.draw()
    jam.asset('map', 'planet'):draw()
end

function jam.states.game.update(dt)

end
