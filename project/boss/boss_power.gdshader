shader_type canvas_item;

uniform sampler2D texture : source_color;

void vertex() {
    // Called for every vertex the material is visible on.
}

void fragment() {
    // UV coordinates of the current pixel
    vec2 uv = UV;

    // Center of the texture (assuming the center is at 0.5, 0.5 in UV space)
    vec2 center = vec2(0.5, 0.5);

    // Calculate the vector from the center to the UV coordinate
    vec2 offset = uv - center;

    // Compute radius and angle
    float radius = length(offset);
    float angle = atan(offset.y, offset.x);

    // Smoothly increase the radius over time for a zoom-out effect
    float adjusted_radius = radius + TIME * 0.2;

    // Limit the zooming effect to avoid excessive stretching
    float clamped_radius = mix(radius, adjusted_radius, 0.5);

    // Recompute the UV coordinates based on the modified radius
    vec2 circular_uv = center + clamped_radius * vec2(cos(angle), sin(angle));

    // Wrap the UV coordinates to repeat the texture seamlessly
    vec2 repeated_uv = fract(circular_uv);

    // Sample the texture with the modified UV coordinates
    vec4 texColor = texture(texture, repeated_uv);

    // Check brightness to identify white regions (brightness > threshold)
    float brightness = dot(texColor.rgb, vec3(0.333)); // Average of RGB for brightness
    float threshold = 0.6; // Define the threshold for "white" regions

    // Generate a random color based on TIME for modulation
    vec3 random_color = vec3(
        0.5 + 0.5 * sin(TIME * 3.0), // Red oscillates
        0.5 + 0.5 * sin(TIME * 2.0 + 1.0), // Green oscillates with offset
        0.5 + 0.5 * sin(TIME * 4.0 + 2.0) // Blue oscillates with offset
    );

    // Modulate white parts, keep black parts unchanged
    vec3 final_color = mix(texColor.rgb, random_color, step(threshold, brightness));

    // Set the final color, keeping the original alpha value
    COLOR = vec4(final_color, texColor.a);
}

