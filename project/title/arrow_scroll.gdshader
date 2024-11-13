shader_type canvas_item;

uniform sampler2D texture;
uniform float scroll_speed : hint_range(0.0, 10.0);

void fragment() {
    vec2 uv = UV;
    
    uv.x += TIME * scroll_speed;
    
    uv.x = mod(uv.x, 1.0);
    uv.y = mod(uv.y, 1.0);

    vec4 color = texture(texture, uv);

    COLOR = color;
}
