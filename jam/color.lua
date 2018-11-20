Color = {}

function Color.rgb(r, g, b, a)
    if not a then a = 255 end
    return r / 255, g / 255, b / 255, a / 255
end

function Color.rgba(r, g, b, a)
    if not a then a = 1.0 end
    return r / 255, g / 255, b / 255, a
end

return Color
