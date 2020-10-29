#version 330 core

in vec2 position;
in vec2 uv;
in vec4 color;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out Vertex {
  vec2 uv;
  vec4 color;
} v;

void main(void)
{
  gl_Position = projection * view * model * vec4(position, 0.0, 1.0);
  v.uv = uv;
  v.color = color;
}
