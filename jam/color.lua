Color = {}

function Color.rgb(r, g, b, a)
    if not a then a = 255 end
    return r / 255, g / 255, b / 255, a / 255
end

function Color.rgba(r, g, b, a)
    if not a then a = 1.0 end
    return r / 255, g / 255, b / 255, a
end

function Color.derive(color, r, g, b, a)
    g = g or r; b = b or r; a = a or 1.0
    return
        math.clamp(color[1] * r, 0, 1),
        math.clamp(color[2] * g, 0, 1),
        math.clamp(color[3] * b, 0, 1),
        math.clamp(color[4] * a, 0, 1)
end

return Color
