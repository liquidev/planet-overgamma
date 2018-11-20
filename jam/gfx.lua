require 'jam/color'

local gfx = {}

gfx.shader = {}

-- example effect:
-- { 'crt', intensity = 0.25 }
function gfx.addEffect(where, fx)
    table.insert(gfx.shader.effects[where], fx)
    return fx
end

function gfx.resetEffects()
    gfx.shader.effects = {
        pre = {}, -- applied to framebuffer before scaling
        post = {} -- applied to framebuffer after scaling
    }
end

gfx.resetEffects()

function gfx._load(args)
    print(' - canvas+buffers')
    gfx.canvas = love.graphics.newCanvas(conf.width, conf.height)
    gfx.shader.buffer1 = love.graphics.newCanvas(conf.width, conf.height)
    gfx.shader.buffer2 = love.graphics.newCanvas(conf.width, conf.height)
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

    -- shader framebuffer
    -- love.graphics.setCanvas(gfx.shader.buffer())
    -- love.graphics.draw(gfx.canvas)
    -- for _, fx in pairs(gfx.shader.effects.pre) do
    --     local shader = jam.asset('shader', fx[1])
    --     for key, val in pairs(fx) do
    --         if key ~= 1 then
    --             shader:send(key, val)
    --         end
    --     end
    --     love.graphics.setShader(shader)
    --     love.graphics.draw(gfx.shader.buffer)
    -- end
    love.graphics.setCanvas(gfx.shader.buffer1)
    love.graphics.clear()
    love.graphics.draw(gfx.canvas)

    for _, fx in pairs(gfx.shader.effects.pre) do
        local shader = jam.asset('shader', fx[1])
        for key, val in pairs(fx) do
            if key ~= 1 then shader:send(key, val) end
        end
        gfx.shader.buffer1, gfx.shader.buffer2 = gfx.shader.buffer2, gfx.shader.buffer1
        love.graphics.setCanvas(gfx.shader.buffer1)
        love.graphics.clear()
        love.graphics.setShader(shader)
        love.graphics.draw(gfx.shader.buffer2)
    end
    love.graphics.setShader()

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
