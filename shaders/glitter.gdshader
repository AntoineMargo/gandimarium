shader_type canvas_item;

/** Noise used for the glitter shape.
* A high frequency is recommended (for example 0.15), but finetune to taste.
* If using an Atlas or Non-Squared texture, the Noise Texture MUST be of the same aspect ratio.
* It is necessary to set up the noise correctly. On the Noise Texture -> Noise craete a FastNoiseLite
* This FastNoiseLite works best with Perlin Noise Type for realistic glitter, or Celluar Noise Type (and turning on Noise Texture -> Invert) for a more rounded shape.
* Using Fractal and Domain Warp inside the FastNoiseLite can help creating a more organic glitter shape.
*/
uniform sampler2D noise_texture: repeat_enable;

// Glitter properties
group_uniforms GlitterProperties;
uniform vec4 glitter_color : source_color = vec4(1.0,1.0,1.0,1.0);
uniform float glitter_size: hint_range(0.0, 1.0, 0.01) = 0.35;
uniform float glitter_hardness: hint_range(0.0, 1.0, 0.01) = 0.35;

group_uniforms HighlightProperties;
/** Glitter highlight speed. */
uniform float highlight_speed = 10.0;
/** Glitter highlight intensity. */
uniform float highlight_intensity: hint_range(0.0, 1.0, 0.05) = 0.25;
/** Glitter highlight band*/
uniform bool highlight_band;

varying vec2 local_vert;

void vertex() {
	local_vert = VERTEX;
}

void fragment() {
	float glitter_highlight_map = (
			mix(
				texture(noise_texture,(local_vert * 0.005) + TIME * highlight_speed * 0.01).r,
				sin((local_vert.x + local_vert.y) * 0.05 + TIME * highlight_speed) * 0.5 + 1.0,
				float(highlight_band)
				)
		);

	// Generate glitter shapes
	float glitter = (
		// Filter the noise to get the glitter shapes
		smoothstep(
			(1.0 - glitter_size),
			1.0 - (glitter_size * glitter_hardness),
			texture(noise_texture, UV).r
			)
		// Apply the highlight map on the glitter.
		* (1.0 - (glitter_highlight_map * clamp(highlight_intensity,0.0,0.65)))
		);

	// Get the Sprite texture
	vec4 sprite_texture = texture(TEXTURE, UV);

	COLOR = mix(sprite_texture, glitter_color, glitter * sprite_texture.a);

	// This is for debug. Uncommenting this will show the Glitter Highlight Map
	//COLOR = vec4(vec3(glitter_highlight_map),1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
