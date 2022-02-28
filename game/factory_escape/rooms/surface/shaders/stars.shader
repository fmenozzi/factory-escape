shader_type canvas_item;

uniform float offset_uv: hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 color = texture(TEXTURE, vec2(UV.x + offset_uv, UV.y));
    if (color.a == 0.0) {
        discard;
    }
    color.a = exp(-4.0 * UV.y);
    COLOR = color;
}