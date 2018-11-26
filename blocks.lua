require 'machines'

blocks = {
    all = {
        {
            name = 'Plants',
            place = 2,
            ingredients = { {id = 0, amt = 2} }
        },
        {
            name = 'Stone',
            place = 19,
            ingredients = { {id = 1, amt = 2} }
        },
        {
            name = 'Light',
            place = { block = 256, entity = machines.Light },
            ingredients = { {id = 2, amt = 1}, {id = 3, amt = 1} }
        },
        {
            name = 'Furnace',
            place = { block = 256, entity = machines.Furnace },
            ingredients = { {id = 5, amt = 3}, {id = 4, amt = 2} }
        },
        {
            name = 'Smelter',
            place = { block = 256, entity = machines.Smelter },
            ingredients = { {id = 5, amt = 3}, {id = 4, amt = 3} }
        },
        {
            name = 'Thermal Gen',
            place = { block = 256, entity = machines.ThermalGen },
            ingredients = { {id = 5, amt = 5}, {id = 4, amt = 3}, {id = 11, amt = 3} }
        },
        {
            name = 'Cache',
            place = { block = 256, entity = machines.Cache },
            ingredients = { {id = 5, amt = 2}, {id = 3, amt = 5}, {id = 12, amt = 2} }
        }
    },

    placeable = {}
}
