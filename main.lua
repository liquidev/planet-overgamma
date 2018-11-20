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

end

function jam.states.game.draw()
    jam.asset('map', 'planet'):draw()
end

function jam.states.game.update(dt)

end
