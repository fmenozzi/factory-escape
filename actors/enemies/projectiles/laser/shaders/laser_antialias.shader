shader_type canvas_item;

// Use the distance from each fragment to the center line as a weight to smooth
// the beam towards each edge. This serves as a poor man's antialiasing, since
// the built-in antialias property in Line2D doesn't seem to work for whatever
// reason.
void fragment() {
    float dist_to_center_line_y_uv = abs(0.5 - UV.y);
    float half_width_uv = 0.5;

    float w = dist_to_center_line_y_uv / half_width_uv;

    COLOR.a = smoothstep(1.0, 0.85, w);
}