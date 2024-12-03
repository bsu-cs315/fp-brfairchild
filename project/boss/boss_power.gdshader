shader_type canvas_item;

uniform sampler2D texture : source_color;
uniform float wobble_speed : hint_range(0.0, 10.0) = 1.0; // Speed of the wobble
uniform float wobble_intensity : hint_range(0.0, 1.0) = 0.1; // Intensity of the wobble
uniform float grow_speed : hint_range(0.0, 2.0) = 0.5; // Speed of the texture growing
uniform float panning_speed : hint_range(0.0, 5.0) = 0.2; // Speed of texture panning
uniform float transparency : hint_range(0.0, 1.0) = 0.5; // Transparency factor (0.0 = fully transparent, 1.0 = no transparency)

void vertex() {
    // Called for every vertex the material is visible on.
}

void fragment() {
    vec2 uv = UV;

    // Apply the panning effect first to the UVs (normal and opposite directions)
    uv += vec2(TIME * panning_speed, 0.0); // Pans horizontally, modify for vertical panning if needed
    vec2 uv_opposite = uv - vec2(TIME * panning_speed * 2.0, 0.0); // Opposite direction panning

    // Make the texture repeat by using fract to wrap UVs around 0-1 range
    uv = fract(uv); // Repeats the texture
    uv_opposite = fract(uv_opposite); // Repeats the texture in the opposite direction

    // Add wobble effect by modifying UV with sine waves (for both directions)
    vec2 wobble = vec2(
        sin(TIME * wobble_speed + uv.y * 10.0) * wobble_intensity,
        cos(TIME * wobble_speed + uv.x * 10.0) * wobble_intensity
    );
    vec2 wobble_opposite = vec2(
        sin(TIME * wobble_speed + uv_opposite.y * 10.0) * wobble_intensity,
        cos(TIME * wobble_speed + uv_opposite.x * 10.0) * wobble_intensity
    );
    uv += wobble;
    uv_opposite += wobble_opposite;

    // Make the texture grow by scaling the uv coordinates over time (both directions)
    float grow_factor = 1.0 + sin(TIME * grow_speed) * 0.5; // Adjust the 0.5 for the desired growth range
    uv = (uv - 0.5) * grow_factor + 0.5; // Scale the uv coordinates while keeping the center at (0.5, 0.5)
    uv_opposite = (uv_opposite - 0.5) * grow_factor + 0.5; // Same scaling for opposite direction

    vec2 center = vec2(0.5, 0.5);
    float max_radius = 0.8;

    float distance = length(uv - center);
    float is_inside_circle = step(distance, max_radius);
    float distance_opposite = length(uv_opposite - center);
    float is_inside_circle_opposite = step(distance_opposite, max_radius);

    // Sample the texture using the modified UVs
    vec4 texColor = texture(texture, uv); 
    vec4 texColor_opposite = texture(texture, uv_opposite); 

    // Combine both directions' colors
    float brightness = dot(texColor.rgb, vec3(0.333)); 
    float threshold = 0.6;

    vec3 random_light_color = vec3(
        0.5 + 0.5 * sin(TIME * 3.0), // Red
        0.5 + 0.5 * sin(TIME * 2.0 + 1.0), // Green
        0.5 + 0.5 * sin(TIME * 4.0 + 2.0) // Blue
    );

    vec3 random_dark_color = vec3(
        0.2 + 0.2 * sin(TIME * 5.0), // Red
        0.2 + 0.2 * sin(TIME * 3.0 + 2.0), // Green 
        0.2 + 0.2 * sin(TIME * 4.0 + 1.0) // Blue 
    );

    vec3 modulated_color = mix(random_dark_color, random_light_color, step(threshold, brightness));
    vec4 final_color = vec4(modulated_color, texColor.a) * is_inside_circle;

    vec3 modulated_color_opposite = mix(random_dark_color, random_light_color, step(threshold, dot(texColor_opposite.rgb, vec3(0.333))));
    vec4 final_color_opposite = vec4(modulated_color_opposite, texColor_opposite.a) * is_inside_circle_opposite;

    // Combine both directions' final colors and apply transparency
    COLOR = mix(final_color, final_color_opposite, 0.5);
    COLOR.a *= transparency; // Apply transparency to the final output
}

