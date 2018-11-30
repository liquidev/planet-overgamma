// Radial wipe
// Copyright (c) iLiquid, 2018
// for use with Love2D

uniform float progress;

uniform float smoothness;
uniform bool invert;

vec4 effect(vec4 tint, Image texture, vec2 tex_coords, vec2 scr_coords) {
    vec4 col = Texel(texture, tex_coords);
    float prog = progress * progress;

    float lightness = smoothstep(
        prog, prog + smoothness,
        clamp(distance(tex_coords, vec2(0.5, 0.5)), 0.0, 1.0));
    if (invert) lightness = 1.0 - lightness;

    col *= lightness;

    return col * tint;
}
