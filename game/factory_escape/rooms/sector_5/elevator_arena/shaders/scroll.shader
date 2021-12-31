shader_type canvas_item;

uniform vec2 direction = vec2(0.0, -1.0);
uniform float offset_uv = 0.0;

void fragment() {
    COLOR = texture(TEXTURE, UV + (direction * offset_uv));
}