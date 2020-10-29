#version 330 core

in Vertex {
  vec2 uv;
  vec4 color;
} v;

uniform sampler2D surface;

out vec4 color;

void main(void)
{
  color = v.color * texture(surface, v.uv);
}
