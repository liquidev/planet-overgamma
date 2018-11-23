maps = {}

function maps.autotile(map)
    map:autotile(1, {
        2,
        19
    })

end

function maps.autosolid(map)
    map:autosolid(1, table.join(
        {range(2, 17)},
        {range(19, 34)}
    ), true)
end

function maps.autoprocess(map)
    maps.autotile(map)
    maps.autosolid(map)
end
