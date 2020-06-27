shader_type canvas_item;

uniform float vignette_power = 0.0;

uniform vec4 vignette_color: hint_color = vec4(vec3(0.0), 1.0);

void fragment() {
    // Multiply the power by the distance to the center of the screen to get the
    // weight for this fragment.
    float weight = vignette_power * distance(SCREEN_UV, vec2(0.5, 0.5));

    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    COLOR.rgb = mix(screen_color.rgb, vignette_color.rgb, weight);
}