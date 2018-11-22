// Radial wipe
// Copyright (c) iLiquid, 2018

uniform float progress;

uniform float smoothness;
uniform bool invert;

vec4 effect(vec4 color, Image texture, vec2 tex_coords, vec2 scr_coords) {
    vec4 col = Texel(texture, tex_coords);

    float lightness = smoothstep(
        progress, progress + smoothness,
        clamp(distance(tex_coords, vec2(0.5, 0.5)), 0.0, 1.0));
    if (invert) lightness = 1.0 - lightness;

    col *= lightness;

    return col;
}
