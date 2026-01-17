shader_type canvas_item;

// Screen texture
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

uniform float wave_speed = 3.0;   // wave loop speed
uniform float wave_freq  = 10.0;  // wave vertical frequency
uniform float wave_width = 1.0;   // wave width

void fragment() {
    // Start with screen UV
    vec2 scale_UV = SCREEN_UV;

    // Calculate horizontal displacement based on sine wave
    vec2 wave_uv_offset;
    wave_uv_offset.x = cos((TIME * wave_speed) + UV.x + UV.y * wave_freq * 2.0)
                       * wave_width * 0.01;

    // Sample the screen texture at displaced coordinates
    COLOR = texture(screen_tex, scale_UV + wave_uv_offset);
}
