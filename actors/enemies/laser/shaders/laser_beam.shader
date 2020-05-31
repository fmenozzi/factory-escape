shader_type canvas_item;

// The color of the beam.
uniform vec4 beam_color : hint_color = vec4(1.0, 0.0, 0.0, 1.0);

// The half-width of the beam in UV space.
uniform float beam_half_width_uv : hint_range(0.0, 0.5) = 0.25;

void fragment() {
    // The y-coordinate of the pixel in UV-space. We don't care about the
    // x-coordinate, since the shader is uniform across all x-values.
    float y = UV.y;

    // The y-distance in UV-space from the current fragment to the horizontal
    // center line. This will be used to determine if the current fragment is
    // inside the beam.
    float dist_to_center_line_y = abs(0.5 - y);

    if (dist_to_center_line_y <= beam_half_width_uv) {
        // Inside the beam. Smooth outer edge slightly.
        COLOR = beam_color;
        float w = dist_to_center_line_y / beam_half_width_uv;
        COLOR.a = smoothstep(1.0, 0.85, w);
    } else {
        // Discard fragments outside the beam.
        discard;
    }
}