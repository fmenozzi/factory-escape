shader_type canvas_item;

// The final color of the sprite at the end of a single flash cycle.
uniform vec4 flash_color : hint_color = vec4(1.0);

// The amount to lerp between the original sprite's color and the flash color.
// This value will be animated by the sprite to produce the flash effect.
uniform float lerp_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 sprite_color = texture(TEXTURE, UV);

    vec3 color = mix(sprite_color.rgb, flash_color.rgb, lerp_amount);

    COLOR = vec4(clamp(color, vec3(0.0), vec3(1.0)), sprite_color.a);
}