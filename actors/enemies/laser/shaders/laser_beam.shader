shader_type canvas_item;

// The color of the outer beam.
uniform vec4 outer_beam_color : hint_color = vec4(1.0, 0.0, 0.0, 1.0);

// The half-width of the outer beam in UV space.
uniform float outer_beam_half_width_uv : hint_range(0.0, 0.5) = 0.25;

// The color of the inner beam.
uniform vec4 inner_beam_color : hint_color = vec4(1.0);

// The half-width of the inner beam in UV space.
uniform float inner_beam_half_width_uv : hint_range(0.0, 0.5) = 0.15;

void fragment() {
    // The y-coordinate of the pixel in UV-space. We don't care about the
    // x-coordinate, since the shader is uniform across all x-values.
    float y = UV.y;

    // The y-distance in UV-space from the current fragment to the horizontal
    // center line. This will be used to determine if the current fragment is
    // inside the beam.
    float dist_to_center_line_y = abs(0.5 - y);

    if (dist_to_center_line_y <= inner_beam_half_width_uv) {
        // Inside inner beam.
        COLOR = inner_beam_color;
    } else if (dist_to_center_line_y <= outer_beam_half_width_uv) {
        // Inside outer beam. Smooth the outer edge slightly.
        COLOR = outer_beam_color;
        float w = dist_to_center_line_y / outer_beam_half_width_uv;
        COLOR.a = smoothstep(1.0, 0.85, w);
    } else {
        // Discard fragments outside outer beam.
        discard;
    }
}