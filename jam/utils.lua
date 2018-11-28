function default(val, def)
    if val == nil then val = def end
    return val
end

function lines(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

function printtable(table)
    local circular = {}
    function pt(tab, indent)
        if indent < 10 then
            for k, v in pairs(tab) do
                if type(v) == 'table' then
                    iscirc = false
                    for i, r in pairs(circular) do
                        if r == v then
                            iscirc = true
                            break
                        end
                    end

                    if not iscirc then
                        print(string.rep('  ', indent)..k..':')
                        pt(v, indent + 1)
                    else
                        print(string.rep('  ', indent)..k..': [circular]')
                    end
                elseif  type(v) == 'string'
                     or type(v) == 'number'
                     or type(v) == 'boolean'
                     or type(v) == 'nil' then
                    print(string.rep('  ', indent)..k..': '..tostring(v))
                elseif type(v) == 'userdata' then
                    print(string.rep('  ', indent)..k..': [userdata]')
                elseif type(v) == 'function' then
                    print(string.rep('  ', indent)..k..': f() ...')
                end
            end
        else
            print('...')
        end
    end
    print('(table):')
    pt(table, 1)
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function math.dist(a, b)
    return ((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2) ^ 0.5
end

function math.sig(num)
    if num > 0 then return 1 end
    if num == 0 then return 0 end
    if num < 0 then return -1 end
end

function math.round(n, precision)
    local mult = 10 ^ (precision or 0)
    return math.floor(n * mult + 0.5) / mult
end

function math.lerp(a, b, t)
	return a + (b - a) * t
end

function math.clamp(v, min, max)
    return math.min(math.max(v, min), max)
end

function string.startswith(str, start)
   return str:sub(1, #start) == start
end

function string.endswith(str, ending)
   return ending == '' or str:sub(-#ending) == ending
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

function bitstonumber(table)
    local num = 0
    for i, v in pairs(table) do
        num = num + (v and 1 or 0) * 2 ^ (i - 1)
    end
    return num
end

function numbertobits(num, bits)
    local bits = bits or math.max(1, select(2, math.frexp(num)))
    local t = {}
    for b = bits, 1, -1 do
        t[b] = math.fmod(num, 2)
        num = math.floor((num - t[b]) / 2)
    end
    return t
end

function table.len(table)
    local len = 0
    for _, _ in pairs(table) do len = len + 1 end
    return len
end

function table.has(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function table.find(table, value)
    for i, v in pairs(table) do
        if v == value then
            return i, v
        end
    end
    return nil
end

function table.shift(tab, amt)
    for i = 1, amt do
        table.insert(tab, 1, table.remove(tab, #tab))
    end
end

function table.join(...)
    local tables = {...}
    local result = {}
    for _, tab in pairs(tables) do
        for _, v in pairs(tab) do
            table.insert(result, v)
        end
    end
    return result
end

function table.fill(n, value)
    local tab = {}
    for i = 1, n do
        if type(value) == 'table' then table.insert(tab, deepcopy(value))
        else table.insert(tab, value) end
    end
    return tab
end

function table.clear(table)
    for k, v in pairs(table) do table[k] = nil end
end

function table.merge(tab, other, overwrite)
    for k, v in pairs(other) do
        if overwrite then tab[k] = v
        else
            tab[k] = tab[k] or v
        end
    end
    return tab
end

function table2D(width, height, init)
    init = default(init, 0)

    local tab = {}
    for i = 1, height do
        tab[i] = {}
        for j = 1, width do
            local v = init
            if type(v) == 'table' then v = deepcopy(init) end
            tab[i][j] = v
        end
    end

    return tab
end

function range(start, stop)
    local r = {}
    for i = start, stop do
        table.insert(r, i)
    end
    return unpack(r)
end

function tern(condition, t, f)
    if condition then return t
    else return f end
end

function chance(n)
    return (love.math.random() <= n)
end
