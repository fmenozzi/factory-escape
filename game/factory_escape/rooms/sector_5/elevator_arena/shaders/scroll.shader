shader_type canvas_item;

uniform vec2 direction = vec2(0.0, -1.0);
uniform float speed_uv = 0.15;

void fragment() {
    COLOR = texture(TEXTURE, UV + (direction * TIME * speed_uv));
}