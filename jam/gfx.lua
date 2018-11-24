require 'jam/color'

local gfx = {}

gfx.shader = {}

-- example effect:
-- { 'crt', intensity = 0.25 }
function gfx.addEffect(where, fx)
    table.insert(gfx.shader.effects[where], fx)
    return fx
end

function gfx.removeEffect(where, fx)
    local i = table.find(gfx.shader.effects[where], fx)
    if i then table.remove(gfx.shader.effects[where], i) end
    return fx
end

function gfx.resetEffects()
    gfx.shader.effects = {
        pre = {}, -- applied to framebuffer before scaling
        post = {} -- applied to framebuffer after scaling
    }

    gfx.shader.wipe = {
        enabled = false, fx = {},
        playuntil = 0, reverse = false,
        callback = nil
    }
end

gfx.resetEffects()

function gfx.wipe(shader, duration, reverse, options, callback)
    if invert == nil then invert = false end

    gfx.shader.wipe.enabled = true
    gfx.shader.wipe.starttime = love.timer.getTime()
    gfx.shader.wipe.duration = duration
    gfx.shader.wipe.reverse = reverse
    gfx.shader.wipe.callback = callback
    local fx = { shader, progress = tern(reverse, 1.0, 0.0) }
    for k, v in pairs(options) do
        fx[k] = v
    end
    gfx.removeEffect('pre', gfx.shader.wipe.fx)
    gfx.shader.wipe.fx = gfx.addEffect('pre', fx)

    return fx
end

gfx.hud = {}

function gfx.drawhud(f)
    table.insert(gfx.hud, f)
end

function gfx._load(args)
    print(' - canvas+buffers')
    gfx.canvas = love.graphics.newCanvas(conf.width, conf.height)
    gfx.shader.buffer1 = love.graphics.newCanvas(conf.width, conf.height)
    gfx.shader.buffer2 = love.graphics.newCanvas(conf.width, conf.height)
end

function gfx._update()
    if gfx.shader.wipe.enabled then
        local time = love.timer.getTime() - gfx.shader.wipe.starttime
        local progress = time / gfx.shader.wipe.duration
        if not gfx.shader.wipe.reverse then gfx.shader.wipe.fx.progress = progress
        else gfx.shader.wipe.fx.progress = 1.0 - progress end
        if progress > 1 then
            if gfx.shader.wipe.callback then gfx.shader.wipe.callback() end
            gfx.removeEffect('pre', gfx.shader.wipe.fx)
            gfx.shader.wipe.enabled = false
        end
    end
end

function gfx._draw()
    jam.scale = math.min(math.floor(jam.width / conf.width), math.floor(jam.height / conf.height))
    love.graphics.clear(0, 0, 0)

    -- off-screen canvas
    love.graphics.setCanvas(gfx.canvas)
    love.graphics.clear(0, 0, 0)
    jam.draw()
    for i, obj in pairs(jam.scheduled) do
        obj:_scheddraw()
        jam.scheduled[i] = nil
    end

    love.graphics.setCanvas(gfx.shader.buffer1)
    love.graphics.clear()
    love.graphics.draw(gfx.canvas)

    for _, fx in pairs(gfx.shader.effects.pre) do
        local shader = jam.asset('shader', fx[1])
        for key, val in pairs(fx) do
            if key ~= 1 then
                if type(val) == 'table' then
                    if val[1] == 'vec' then
                        shader:send(key, {unpack(val, 2)})
                    else
                        shader:send(key, unpack(val))
                    end
                else
                    shader:send(key, val)
                end
            end
        end
        gfx.shader.buffer1, gfx.shader.buffer2 = gfx.shader.buffer2, gfx.shader.buffer1
        love.graphics.setCanvas(gfx.shader.buffer1)
        love.graphics.clear()
        love.graphics.setShader(shader)
        love.graphics.draw(gfx.shader.buffer2)
    end
    love.graphics.setShader()

    for i, f in pairs(gfx.hud) do
        f()
        table.remove(gfx.hud, i)
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
    love.graphics.draw(gfx.shader.buffer1)
    love.graphics.pop()
end

return gfx
