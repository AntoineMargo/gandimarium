shader_type canvas_item;

/* --- Grayscale --- */
uniform float grayscale_amount : hint_range(0.0, 1.0) = 0.0;

/* --- Wounded Tint --- */
uniform float wounded_amount   : hint_range(0.0, 1.0) = 0.0;
uniform vec3 wounded_color = vec3(1.0, 0.1, 0.1);
uniform float wounded_strength : hint_range(0.0, 3.0) = 1.5;

/* --- Hit Flash --- */
uniform float hit_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec3 hit_color = vec3(1.0, 1.0, 0.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 color = tex.rgb;

	/* --- Grayscale --- */
	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(color, vec3(gray), grayscale_amount);

	/* --- Wounded Tint --- */
	vec3 wounded = mix(color, wounded_color, wounded_strength);
	color = mix(color, wounded, wounded_amount);

	/* --- Hit Flash (last, so it dominates visually) --- */
	color = mix(color, hit_color, hit_intensity);

	COLOR = vec4(color, tex.a);
}
