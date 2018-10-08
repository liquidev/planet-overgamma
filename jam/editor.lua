require 'jam/map'

jam.states.__jam_editor__ = {}

do
    map = Map:new()
    mode = 'map-edit'

    function jam.states.__jam_editor__.draw()
        if mode == 'map-edit' then
            love.window.setTitle('lovejam map editor')
        end
    end

    function jam.states.__jam_editor__.update(dt)

    end
end
