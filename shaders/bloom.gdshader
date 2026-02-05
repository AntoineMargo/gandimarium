shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 0.0, 1.0); // line center color
uniform float glow_falloff : hint_range(0.0, 1.0) = 0.8; // how far alpha fades out (0 = no fade, 1 = full fade)
uniform float pulse_speed : hint_range(0.0, 10.0) = 0.0; // optional breathing
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.2; // optional pulse intensity

void fragment() {
    // Distance from the center of the line (0=center, 1=edge)
    float dist = abs(UV.y - 0.5) * 2.0;

    // Alpha tapers from center outwards
    float alpha = glow_color.a * max(1.0 - dist * glow_falloff, 0.0);

    // Optional pulse
    if (pulse_speed > 0.0) {
        alpha *= 1.0 + sin(TIME * pulse_speed) * pulse_strength;
    }

    COLOR = vec4(glow_color.rgb, alpha);
}
