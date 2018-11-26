local Light = Machine:extend('machine.light', 'Light')
Light.__index = Light

Light.sprframe = 0

function Light:init(dt)
    Machine.init(self)
end

function Light:update(dt)
    Machine.update(self, dt)

    mines.light(self.pos.x, self.pos.y, 0.6, Color.rgb(255, 246, 211))
end

return Light
