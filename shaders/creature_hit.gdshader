shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tint : source_color = vec4(1., 1., 0., 1.);

void fragment() {
    vec4 previous_color = texture(TEXTURE, UV);
    vec4 tinted = mix(previous_color, vec4(tint.rgb, previous_color.a), intensity);
    COLOR = tinted;
}