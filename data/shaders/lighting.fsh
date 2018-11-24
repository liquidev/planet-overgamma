// Simple lighting
// Copyright (c) iLiquid, 2018
// for use with Love2D

#define LIGHTS 8

uniform vec4 ambient;

uniform vec3 light_positions[LIGHTS];
uniform vec4 light_colors[LIGHTS];

vec4 effect(vec4 tint, Image texture, vec2 tex_coords, vec2 scr_coords) {
    vec4 lightness = vec4(0.0, 0.0, 0.0, 0.0);

    for (int i = 0; i < LIGHTS; i++) {
        vec2 rel_pos = light_positions[i].xy / love_ScreenSize.xy;


        vec4 intensity = vec4(0.0);
        if (light_positions[i].z != 0) intensity = vec4(1.0 - clamp(
            distance(rel_pos, tex_coords) / light_positions[i].z, 0.0, 1.0));

        lightness += light_colors[i] * intensity;
    }

    lightness += ambient;

    vec4 col = Texel(texture, tex_coords) * lightness;
    return col * tint;
}
