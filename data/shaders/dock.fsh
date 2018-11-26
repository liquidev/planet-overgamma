// Horizontal linear gradient
// Copyright (c) iLiquid, 2018
// for use with Love2D

vec4 effect(vec4 tint, Image texture, vec2 tex_coords, vec2 scr_coords) {
    vec4 col = Texel(texture, tex_coords);

    float a = 1.0 - abs(48.0 - scr_coords.y) / 32.0;
    col.w *= a / 1.5;

    return col * tint;
}
