shader_type canvas_item;

/* Godot 4 replacement for SCREEN_TEXTURE */
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

uniform vec2 center;

uniform float force;
uniform float size;
uniform float blast;

uniform vec2 direction;
uniform float aperture : hint_range(0.0, 3.141516, 0.001);

uniform float red_offset   : hint_range(0.0, 2.0, 0.001);
uniform float green_offset : hint_range(0.0, 2.0, 0.001);
uniform float blue_offset  : hint_range(0.0, 2.0, 0.001);

vec2 scale(vec2 coord, vec2 scale_factor) {
	return coord * scale_factor;
}

void fragment() {
	/* Screen-space distance */
	float dist = distance(FRAGCOORD.xy, center);
	vec2 norm = normalize(FRAGCOORD.xy - center);

	/* Directional cone mask */
	vec2 dir = normalize(vec2(-direction.x, direction.y));
	float angle = acos(clamp(dot(dir, -norm), -1.0, 1.0));

	float mask =
		cos((angle * 1.5707963268) / (aperture + 0.00001)) *
		step(angle, aperture) *
		force;

	/* Radial blast mask */
	float blast_mask = smoothstep(blast - size * 0.5, blast, dist);
	float total_size = blast + size * 0.5;

	vec3 offsets = vec3(red_offset, green_offset, blue_offset);
	vec3 forces = offsets * mask * blast_mask;

	vec3 raw_eases = total_size * offsets;
	raw_eases = clamp(dist / max(raw_eases, vec3(0.00001)), vec3(0.0), vec3(1.0));

	vec3 easings = pow(raw_eases, forces);
	vec3 deforms = easings * dist;

	vec2 base_uv = center * SCREEN_PIXEL_SIZE;

	COLOR = vec4(
		texture(screen_tex, scale(base_uv + deforms.r * norm, SCREEN_PIXEL_SIZE)).r,
		texture(screen_tex, scale(base_uv + deforms.g * norm, SCREEN_PIXEL_SIZE)).g,
		texture(screen_tex, scale(base_uv + deforms.b * norm, SCREEN_PIXEL_SIZE)).b,
		1.0
	);
}
