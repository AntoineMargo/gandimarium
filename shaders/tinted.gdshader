shader_type canvas_item;

uniform float wound_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec3 wound_color = vec3(1.0, 0.1, 0.1); // strong red tint

void fragment() {
    vec4 col = texture(TEXTURE, UV);

    // Multiply keeps shading/detail instead of flat replacement
    vec3 tinted = col.rgb * wound_color;

    // Blend between normal and wounded
    vec3 final_color = mix(col.rgb, tinted, wound_amount);

    COLOR = vec4(final_color, col.a);
}

