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
            name = 'Sand',
            place = 35,
            ingredients = { {id = 15, amt = 2} }
        },
        {
            name = 'Vine',
            place = 51,
            ingredients = { {id = 0, amt = 2} }
        },
        -- devices
        {
            name = 'Light',
            place = { block = 256, entity = machines.Light },
            ingredients = { {id = 2, amt = 1}, {id = 3, amt = 1} }
        },
        -- energy production
        {
            name = 'Furnace',
            place = { block = 256, entity = machines.Furnace },
            ingredients = { {id = 5, amt = 3}, {id = 4, amt = 2} }
        },
        {
            name = 'Heating Coil',
            place = { block = 256, entity = machines.HeatingCoil },
            ingredients = { {id = 5, amt = 3}, {id = 4, amt = 5}, {id = 13, amt = 1} }
        },
        {
            name = 'Thermal Gen',
            place = { block = 256, entity = machines.ThermalGen },
            ingredients = { {id = 5, amt = 5}, {id = 4, amt = 3}, {id = 11, amt = 3} }
        },
        {
            name = 'Solar Panel',
            place = { block = 256, entity = machines.SolarPanel },
            ingredients = { {id = 5, amt = 5}, {id = 14, amt = 8} }
        },
        -- resource production
        {
            name = 'Smelter',
            place = { block = 256, entity = machines.Smelter },
            ingredients = { {id = 5, amt = 3}, {id = 4, amt = 3} }
        },
        {
            name = 'Pulverizer',
            place = { block = 256, entity = machines.Pulverizer },
            ingredients = { {id = 5, amt = 3}, {id = 4, amt = 2}, {id = 12, amt = 5} }
        },
        {
            name = 'Miner',
            place = { block = 256, entity = machines.Miner },
            ingredients = { {id = 5, amt = 7}, {id = 11, amt = 5}, {id = 12, amt = 5}, {id = 8, amt = 1} }
        },
        -- storage
        {
            name = 'Cache',
            place = { block = 256, entity = machines.Cache },
            ingredients = { {id = 5, amt = 2}, {id = 3, amt = 5}, {id = 12, amt = 2} }
        },
        {
            name = 'Cache Drop.',
            place = { block = 256, entity = machines.CacheDropper },
            ingredients = { {id = 5, amt = 1}, {id = 10, amt = 1} }
        },
        {
            name = 'Channel',
            place = { block = 256, entity = machines.Channel },
            ingredients = { {id = 5, amt = 5}, {id = 8, amt = 2}, {id = 13, amt = 5} }
        },
        {
            name = 'Power Cell',
            place = { block = 256, entity = machines.PowerCell },
            ingredients = { {id = 5, amt = 2}, {id = 7, amt = 2}, {id = 13, amt = 5} }
        },
    },

    placeable = {}
}
