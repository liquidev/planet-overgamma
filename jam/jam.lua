require 'jam/object'
require 'jam/vector'
require 'jam/hitbox'

conf = require '../jamconf'

jam = {
    scheduled = {},

    activemap = nil,

    mouse = Vector:new(),
    states = {},
    state = 'game',

    shakedata = nil
}

function jam.setstate(which)
    jam.state = which
    if jam.states[which].begin then jam.states[which].begin() end
end

require 'jam/editor'

function jam.load() print('ld') end
function jam.draw() end
function jam.update(dt) end

require 'jam/assets'
function jam.loadAssets()
    jam.assets.loadTilesets()
    jam.assets.loadSprites()
    jam.assets.loadFonts()
    jam.assets.loadSounds()
    jam.assets.loadMaps()
end

function jam.scheduledraw(object)
    table.insert(jam.scheduled, object)
end

jam.states.game = {}
function jam.states.game.draw() end
function jam.states.game.update(dt) end

function jam.drawstate()
    jam.states[jam.state].draw()
end

function jam.updatestate(dt)
    jam.states[jam.state].update(dt)
end

function jam.spawn(entity)
    table.insert(jam.activemap.instance.entities, entity)
end

function jam.shake(time, magnitude)
    jam.shakedata = {
        stopat = love.timer.getTime() + time / 1000,
        magnitude = magnitude
    }
end

function jam.draw()
    jam.drawstate()
end

function jam.update(dt)
    jam.updatestate(dt)
end

function love.load(args)
    print('lovejam by iLiquid - loading')
    print(' - settings')
    love.graphics.setDefaultFilter('nearest', 'nearest', 1)

    print(' - window')
    love.window.setMode(conf.width * conf.defaultScale, conf.height * conf.defaultScale, {
        resizable = true,
        minwidth = conf.width,
        minheight = conf.height
    })
    love.window.setTitle(conf.name)
    jam.scale = conf.defaultScale

    print(' - assets')
    jam.loadAssets()

    print(' - canvas')
    jam.canvas = love.graphics.newCanvas(conf.width, conf.height)

    print(' - user load()')
    print(jam.load)
    jam.load()

    if args[1] == 'edit' then
        print(' - initialize edit mode')
        jam.setstate('__jam_editor__')
    end
end

function love.update(dt)
    width, height = love.graphics.getDimensions()
    cwidth, cheight = jam.canvas:getDimensions()
    canvasx = width / 2 - cwidth * jam.scale / 2
    canvasy = height / 2 - cheight * jam.scale / 2

    jam.mouse.x = math.floor((love.mouse.getX() - canvasx) / jam.scale)
    jam.mouse.y = math.floor((love.mouse.getY() - canvasy) / jam.scale)

    jam.update(dt)
    if jam.activemap then
        jam.activemap:run(dt)
    end


end

function love.draw()
    jam.scale = math.min(math.floor(width / conf.width), math.floor(height / conf.height))
    love.graphics.clear(0, 0, 0)

    -- off-screen canvas
    love.graphics.setCanvas(jam.canvas)
    love.graphics.clear(0, 0, 0)
    jam.draw()
    for i, obj in pairs(jam.scheduled) do
        obj:_scheddraw()
        jam.scheduled[i] = nil
    end

    -- scaled
    love.graphics.setCanvas()
    love.graphics.push()
    if jam.shakedata then
        time = love.timer.getTime()
        if time < jam.shakedata.stopat then
            love.graphics.translate(
                    love.math.random(-jam.shakedata.magnitude, jam.shakedata.magnitude),
                    love.math.random(-jam.shakedata.magnitude, jam.shakedata.magnitude))
        end
    end
    love.graphics.translate(canvasx, canvasy)
    love.graphics.scale(jam.scale)
    love.graphics.draw(jam.canvas)
    love.graphics.pop()
end

local function _map_callback(name, ...)
    local arg = {...}
    if jam.activemap then
        jam.activemap:eachEntity(function (entity)
            if entity[name] then
                entity[name](entity, unpack(arg))
            end
        end)
    end
end

local function _state_callback(name, ...)
    local arg = {...}
    if jam.states[jam.state][name] then
        jam.states[jam.state][name](unpack(arg))
    end
end

local function _fire_callbacks(name, ...)
    _map_callback(name, ...)
    _state_callback(name, ...)
end

function love.keypressed(...) _fire_callbacks('keypressed', ...) end
function love.keyreleased(...) _fire_callbacks('keyreleased', ...) end
function love.mousemoved(...) _fire_callbacks('mousemoved', ...) end
function love.mousepressed(...) _fire_callbacks('mousepressed', ...) end
function love.mousereleased(...) _fire_callbacks('mousereleased', ...) end
function love.wheelmoved(...) _fire_callbacks('wheelmoved', ...) end

return jam
