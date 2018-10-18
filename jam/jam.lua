require 'jam/stringbuffer'

require 'jam/object'
require 'jam/vector'
require 'jam/hitbox'

conf = require '../jamconf'

jam = {
    args = {},

    scheduled = {},

    activemap = nil,
    updatemap = true,

    mouse = Vector:new(),
    states = {},
    state = 'game',

    shakedata = nil
}

function jam.arg(pattern)
    for _, v in pairs(jam.args) do
        local find = { v:match(pattern) }
        if find[1] then
            return unpack(find)
        end
    end
    return nil
end

function jam.setstate(which)
    jam.state = which
    if jam.states[which].begin then jam.states[which].begin() end
end

require 'jam/editor'

function jam.load() end
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

function jam.despawn(entity)
    local i = table.find(jam.activemap.instance.entities, entity)
    table.remove(jam.activemap.instance.entities, i)
end

function jam.noupdate()
    jam.updatemap = false
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

    jam.args = args

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
    jam.load()

    if jam.arg('%-edit') then
        print(' - initialize edit mode')
        local map = jam.arg('%-M(.+)')
        if map then jam.states.__jam_editor__.map = map end
        jam.setstate('__jam_editor__')
    end
end

function love.update(dt)
    jam.width, jam.height = love.graphics.getDimensions()
    jam.cwidth, jam.cheight = jam.canvas:getDimensions()
    jam.canvasx = jam.width / 2 - jam.cwidth * jam.scale / 2
    jam.canvasy = jam.height / 2 - jam.cheight * jam.scale / 2

    jam.mouse.x = math.floor((love.mouse.getX() - jam.canvasx) / jam.scale)
    jam.mouse.y = math.floor((love.mouse.getY() - jam.canvasy) / jam.scale)

    jam.update(dt)
    if jam.activemap and jam.updatemap then
        jam.activemap:run(dt)
    else
        jam.updatemap = true
    end
end

function love.draw()
    jam.scale = math.min(math.floor(jam.width / conf.width), math.floor(jam.height / conf.height))
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
    love.graphics.translate(jam.canvasx, jam.canvasy)
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
    if jam.updatemap then _map_callback(name, ...) end
    _state_callback(name, ...)
end

function love.keypressed(...)
    if love.keyboard.isScancodeDown('f1') then
        love.graphics.captureScreenshot(os.date('%Y-%m-%d %H%M%S')..'.png')
        print('lj: captured screenshot')
    else
        _fire_callbacks('keypressed', ...)
    end
end
function love.keyreleased(...) _fire_callbacks('keyreleased', ...) end
function love.mousemoved(...) _fire_callbacks('mousemoved', ...) end
function love.mousepressed(...) _fire_callbacks('mousepressed', ...) end
function love.mousereleased(...) _fire_callbacks('mousereleased', ...) end
function love.wheelmoved(...) _fire_callbacks('wheelmoved', ...) end
function love.keyreleased(...) _map_callback('keyreleased', ...) end
function love.mousemoved(...) _map_callback('mousemoved', ...) end
function love.mousepressed(...) _map_callback('mousepressed', ...) end
function love.mousereleased(...) _map_callback('mousereleased', ...) end

return jam
