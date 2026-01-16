shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Glow/outline color
uniform float glowSize : hint_range(0.0, 300.0) = 15.0;
uniform int glowDensity : hint_range(0, 30) = 3;
uniform int glowRadialCoverage : hint_range(0, 32) = 4;
uniform float glowAngle : hint_range(0.0, 6.28) = 1.57;
uniform float glowSharpness : hint_range(0.0, 5.0) = 1.0;
uniform float alphaThreshold : hint_range(0.0, 1.0) = 0.2;

void fragment() {
    vec4 col = texture(TEXTURE, UV); // Original pixel
    vec4 final_col = col;             // Start with original color

    vec2 pixel_size = TEXTURE_PIXEL_SIZE; // Size of 1 pixel in UV space
    float alph = 0.0;

    for (int i = 0; i < glowRadialCoverage; i++) {
        for (int j = 0; j < glowDensity; j++) {
            float radians360 = 6.28;
            float angle = (radians360 / float(glowRadialCoverage)) * float(i + 1) + glowAngle;
            float dist = glowSize * float(j + 1) / float(glowDensity);
            vec2 pixel_coor = vec2(sin(angle), cos(angle));
            vec4 tex = texture(TEXTURE, UV + pixel_coor * pixel_size * dist);

            float distFrom = float(glowDensity - j) / float(glowDensity);
            float sharpness = mix(0.0, 1.0, pow(distFrom, glowSharpness));
            alph += (tex.a * line_color.a) * sharpness;
        }
    }

    if (col.a < alphaThreshold) {
        final_col.rgb = line_color.rgb;
        final_col.a = alph;
    }

    COLOR = final_col;
}
