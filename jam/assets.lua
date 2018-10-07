require 'jam/atlas'
require 'jam/map'

jam.assets = {}

function jam.assets.loadTilesets()
    jam.assets.tilesets = {}
    tilesets = love.filesystem.getDirectoryItems('data/tilesets')
    for _, v in pairs(tilesets) do
        print('   - tileset: '..v)
        name = v:match('(.+)%..+')
        tileset = Atlas:new(love.graphics.newImage('data/tilesets/'..v), Map.tilesize[1], Map.tilesize[2])
        jam.assets.tilesets[name] = tileset
    end
end

function jam.assets.loadSprites()
    jam.assets.sprites = {}
    sprites = love.filesystem.getDirectoryItems('data/sprites')
    for _, v in pairs(sprites) do
        name, ext = v:match('(.+)%.(.+)')
        if ext == 'png' then
            data = { width = 8, height = 8 }

            if love.filesystem.getInfo('data/sprites/'..name..'.lua') then
                data = require('data/sprites/'..name)
            end
            print('   - sprite: '..v..' { '..data.width..', '..data.height..' }')
            spritesheet = Atlas:new(love.graphics.newImage('data/sprites/'..v), data.width, data.height)
            jam.assets.sprites[name] = spritesheet
        end
    end
end

function jam.assets.loadFonts()
    jam.assets.fonts = {}
    fonts = love.filesystem.getDirectoryItems('data/fonts')
    for _, v in pairs(fonts) do
        name, ext = v:match('(.+)%.(.+)')
        data = { size = 8 }
        if ext == 'ttf' then
            print('   - font: '..v)
            if love.filesystem.getInfo('data/fonts/'..name..'.lua') then
                data = require('data/fonts/'..name)
            end
            jam.assets.fonts[name] = love.graphics.newFont('data/fonts/'..v, data.size)
        end
    end
end

function jam.assets.loadSounds()
    jam.assets.sounds = {}
    sounds = love.filesystem.getDirectoryItems('data/sounds')
    for _, v in pairs(sounds) do
        print('   - sound: '..v)
        name = v:match('(.+)%..+')
        sound = love.audio.newSource('data/sounds/'..v, 'static')
        jam.assets.sounds[name] = sound
    end
end

function jam.assets.loadMaps()
    jam.assets.maps = {}
    maps = love.filesystem.getDirectoryItems('data/maps')
    for _, v in pairs(maps) do
        print('   - map: '..v)
        name = v:match('(.+)%..+')
        map = Map:new(v)
        jam.assets.maps[name] = map
    end
end
