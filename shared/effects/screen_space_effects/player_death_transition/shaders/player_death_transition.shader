shader_type canvas_item;

// The UV-coordinates of the center of the player on the screen. This will be
// set programmatically based on the player's position when they die.
uniform vec2 player_center_uv = vec2(0.5, 0.5);

// The radius of the effect in UV space. This will be set programmatically as
// part of the player death sequence.
uniform float effect_radius_uv: hint_range(0.0, 1.0) = 0;

void fragment() {
    // The distance from the player center to the current fragment in UV space.
    float distance_to_player_center_uv = distance(UV, player_center_uv);

    // Determine whether the current fragment is within the effect radius.
    float within_radius = step(distance_to_player_center_uv, effect_radius_uv);

    // Color the current fragment black, and use whether the fragment is within
    // the effect radius to determine the alpha.
    COLOR = vec4(vec3(0.0), within_radius);
}