function lines(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

function printtable(table)
    circular = {}
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

function string.endswith(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

function bitstonumber(table)
    num = 0
    for i, v in pairs(table) do
        num = num + (v and 1 or 0) * 2 ^ (i - 1)
    end
    return num
end
