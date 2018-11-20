--[[
    Planet Overgamma+lovejam alpha (c) iLiquid 2018
    arcade shooter where you spam to win
    licensed under the ISC license
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
