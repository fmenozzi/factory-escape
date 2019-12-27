shader_type canvas_item;
render_mode blend_add;

uniform float radius_uv : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    // The current pixel's UV coordinate.
    vec2 p = UV;

    // The UV coordinate of the bottom center of the sprite, which corresponds
    // to the base of the lamp.
    vec2 c = vec2(0.5, 1.0);

    // For all points within the circle centered at C with the given radius,
    // have the light fade as it leaves the center by smoothly blending the
    // alpha from 1.0 (the center) to 0.0 (the edge).
    COLOR.a = smoothstep(1.0, 0.0, distance(p, c) / radius_uv);
}