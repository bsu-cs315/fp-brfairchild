shader_type canvas_item;

uniform sampler2D texture : source_color;
uniform float wobble_speed : hint_range(0.0, 10.0) = 1.0;
uniform float wobble_intensity : hint_range(0.0, 1.0) = 0.1;
uniform float grow_speed : hint_range(0.0, 2.0) = 0.5;
uniform float panning_speed : hint_range(0.0, 5.0) = 0.2;
uniform float transparency : hint_range(0.0, 1.0) = 0.5;

void vertex() {
    // Called for every vertex the material is visible on.
}

void fragment() {
    vec2 uv = UV;
    uv += vec2(TIME * panning_speed, 0.0);
    vec2 uv_opposite = uv - vec2(TIME * panning_speed * 2.0, 0.0);
    uv = fract(uv); 
    uv_opposite = fract(uv_opposite); 

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
    float grow_factor = 1.0 + sin(TIME * grow_speed) * 0.5; 
    uv = (uv - 0.5) * grow_factor + 0.5;
    uv_opposite = (uv_opposite - 0.5) * grow_factor + 0.5;

    vec2 center = vec2(0.5, 0.5);
    float max_radius = 0.8;

    float distance = length(uv - center);
    float is_inside_circle = step(distance, max_radius);
    float distance_opposite = length(uv_opposite - center);
    float is_inside_circle_opposite = step(distance_opposite, max_radius);

    vec4 texColor = texture(texture, uv); 
    vec4 texColor_opposite = texture(texture, uv_opposite); 

    // Combine
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

    // Combine both
    COLOR = mix(final_color, final_color_opposite, 0.5);
    COLOR.a *= transparency;
}

