shader_type canvas_item;

uniform vec4 surface_color: hint_color = vec4(0.0, 0.0, 1.0, 1.0);
uniform vec4 deep_color: hint_color = vec4(0.0, 1.0, 0.0, 1.0);

uniform float offset_y_uv: hint_range(-0.5, 0.5) = 0.0;

void fragment() {
    COLOR = mix(surface_color, deep_color, UV.y + offset_y_uv);
}