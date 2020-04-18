shader_type canvas_item;

// The color of the beam impact.
uniform vec4 impact_color : hint_color = vec4(1.0, 0.0, 0.0, 1.0);

// The radius of the impact effect in UV-space. This value will be animated to
// give a nice "wobble" effect.
uniform float impact_radius_uv : hint_range(0.0, 0.5) = 0.5;

void fragment() {
    // Discard fragments outside the impact circle's radius.
    float dist_to_center = distance(UV, vec2(0.5, 0.5));
    if (dist_to_center > impact_radius_uv) {
        discard;
    }

    // Apply smoothing to the circle's edge.
    COLOR = impact_color;
    COLOR.a = smoothstep(1.0, 0.35, dist_to_center / impact_radius_uv);
}