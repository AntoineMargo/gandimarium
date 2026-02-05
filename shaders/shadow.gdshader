shader_type canvas_item;

uniform vec2 shadow_offset = vec2(2.0, 2.0);
uniform vec4 shadow_color = vec4(0.0, 0.0, 0.0, 0.5);

void vertex() {
    VERTEX += shadow_offset; // move vertices for shadow
}

void fragment() {
    COLOR = shadow_color;
}
