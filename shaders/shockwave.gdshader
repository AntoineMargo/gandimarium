shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform vec2 center = vec2(0.5);
uniform float force = 0.02;
uniform float size = 0.3;
uniform float thickness = 0.05;

void fragment() {
    float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;

    vec2 scaled_uv = (SCREEN_UV - vec2(0.5, 0.5)) / vec2(ratio, 1.0) + vec2(0.5, 0.5);

    float dist = length(scaled_uv - center);

    float mask =
        (1.0 - smoothstep(size - 0.1, size, dist)) *
        smoothstep(size - thickness - 0.1, size - thickness, dist);

    vec2 dir = scaled_uv - center;
    vec2 disp = normalize(dir + 0.0001) * force * mask;

    COLOR = texture(screen_texture, SCREEN_UV - disp);
}
