shader_type canvas_item;

uniform vec4 ring_color : source_color = vec4(0.1, 1.0, 0.1, 1.0); // bright green
uniform float radius : hint_range(0.0, 0.5) = 0.45;
uniform float thickness : hint_range(0.001, 0.2) = 0.04;
uniform float fade : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    // Center UV around (0.5, 0.5)
    vec2 centered_uv = UV - vec2(0.5);
    float dist = length(centered_uv);

    // Ring boundaries
    float outer = radius;
    float inner = radius - thickness;

    // Fade inward (smooth edge)
    float ring = smoothstep(outer, outer - 0.005, dist)
               * smoothstep(inner, inner + thickness * fade, dist);

    COLOR = vec4(ring_color.rgb, ring * ring_color.a);
}
