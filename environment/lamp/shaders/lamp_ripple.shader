shader_type canvas_item;

// The radius of the ripple effect in UV space. This value will be animated
// outside of the shader to provide a moving ripple effect.
uniform float ripple_radius_uv : hint_range(0.0, 0.5) = 0.0;

// The width of the ripple ring effect in UV space.
uniform float ripple_width_uv : hint_range(0.0, 1.0) = 0.1;

// The color of the ripple.
uniform vec4 ripple_color : hint_color = vec4(1.0, 0.0, 0.0, 1.0);

// The multiplier applied to the final alpha value. This value will be animated
// outside of the shader to provide a fade-out effect as the ripple moves.
uniform float alpha_multiplier : hint_range(0.0, 1.0) = 1.0;

// Returns 1.0 if the pixel with the given distance to the center is within half
// the ripple's width from the ripple's radius, else 0.0. This forms the ring of
// the ripple effect.
float ring(float dist_to_center) {
    float half_width = 0.5 * ripple_width_uv;
    float outer_circle_radius = ripple_radius_uv + half_width;
    float inner_circle_radius = ripple_radius_uv - half_width;

    bool in_outer_circle = dist_to_center <= outer_circle_radius;
    bool in_inner_circle = dist_to_center <= inner_circle_radius;

    return float(in_outer_circle && !in_inner_circle);
}

void fragment() {
    // The current pixel's UV coordinate.
    vec2 p = UV;

    // The UV coordinate of the center of the sprite.
    vec2 c = vec2(0.5, 0.5);

    // The UV distance from the current pixel to the sprite's center.
    float dist = distance(p, c);

    // The initial alpha value is just whether or not the pixel is within the
    // ring of the ripple effect.
    float alpha = ring(dist);

    // Rather than having a uniform ring color, use smoothing to achieve a glow
    // effect on the edges of the ring. Smooth towards the center of the ring
    // from either side by lerping the alpha accordingly.
    float w = (dist - (ripple_radius_uv - ripple_width_uv / 2.0)) / ripple_width_uv;
    if (dist < ripple_radius_uv) {
        alpha *= smoothstep(0.0, 1.0, w);
    } else {
        alpha *= smoothstep(1.0, 0.0, w);
    }

    // Discard the lower half of the ripple.
    alpha *= float(p.y <= 0.5);

    // Incorporate alpha multiplier uniform so that we can control the general
    // change in alpha as part of the ripple animation (e.g. fade out as the
    // ripple travels outwards).
    alpha *= alpha_multiplier;

    COLOR = vec4(ripple_color.rgb, alpha);
}