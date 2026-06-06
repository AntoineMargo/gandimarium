shader_type canvas_item;

/* ============================================================
 * UV DISTORTION STAGE
 * ============================================================
 *
 * Effects that modify the sprite's shape or texture sampling.
 * Examples:
 * - Melt
 * - Teleport distortion
 * - Wobble
 * - Drunk/confusion effect
 * - Ghost shimmer
 *
 */

uniform float melt_amount : hint_range(0.0, 1.0) = 0.0;


/* ============================================================
 * COLOR MODIFICATION STAGE
 * ============================================================
 *
 * Effects that alter the sprite's colors.
 * Examples:
 * - Grayscale
 * - Wounded tint
 * - Poison tint
 * - Frozen tint
 * - Petrification
 *
 */

uniform float grayscale_amount : hint_range(0.0, 1.0) = 0.0;

uniform float wounded_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec3 wounded_color = vec3(1.0, 0.1, 0.1);
uniform float wounded_strength : hint_range(0.0, 3.0) = 1.5;


/* ============================================================
 * EMISSION / FLASH STAGE
 * ============================================================
 *
 * Effects that visually dominate the final color.
 * Examples:
 * - Hit flashes
 * - Magical charge glow
 * - Holy radiance
 * - Electricity surge
 *
 */

uniform float hit_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec3 hit_color = vec3(1.0, 1.0, 0.0);


/* ============================================================
 * STATUS AURA / MAGIC TINT
 * ============================================================ */

uniform float aura_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec3 aura_color = vec3(0.7, 0.85, 1.0);

/* ============================================================
 * ALPHA / MASK STAGE
 * ============================================================
 *
 * Effects that alter transparency.
 * Examples:
 * - Fade out
 * - Dissolve
 * - Stealth
 * - Teleport disappearance
 *
 */

uniform float fade_amount : hint_range(0.0, 1.0) = 0.0;


/* ============================================================
 * UV PROCESSING
 * ============================================================
 */

vec2 process_uv(vec2 uv) {

	// Example melt effect placeholder.
	// Disabled by default.
	if (melt_amount > 0.0) {
		uv.x += sin(uv.y * 20.0 + TIME * 5.0)
			* melt_amount
			* 0.02;
	}

	return uv;
}


/* ============================================================
 * COLOR PROCESSING
 * ============================================================
 */

vec3 process_color(vec3 color) {

	/* --- Grayscale --- */

	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(color, vec3(gray), grayscale_amount);

	/* --- Wounded Tint --- */

	vec3 wounded = mix(
		color,
		wounded_color,
		wounded_strength
	);

	color = mix(
		color,
		wounded,
		wounded_amount
	);

	return color;
}

/* ============================================================
 * PULSE
 * ============================================================
 */

uniform float pulse_speed = 2.0;
uniform float pulse_offset = 0.0;
uniform float pulse_sharpness = 0.0;

float pulse(float t, float speed, float offset, float sharpness) {

	float x = sin(t * speed + offset);

	x = x * 0.5 + 0.5;

	if (sharpness > 0.0) {
		x = pow(x, mix(1.0, 6.0, sharpness));
	}

	return x;
}

/* ============================================================
 * EMISSION PROCESSING
 * ============================================================
 */

vec3 process_emission(vec3 color) {

	float p = pulse(
		TIME,
		pulse_speed,
		pulse_offset,
		pulse_sharpness
	);

	float aura_strength = aura_amount * mix(0.75, 1.5, p);

	color += aura_color * aura_strength * 0.25;

	color = mix(
		color,
		hit_color,
		hit_intensity
	);

	return clamp(color, 0.0, 1.0);
}

/* ============================================================
 * ALPHA PROCESSING
 * ============================================================
 */

float process_alpha(float alpha, vec2 uv) {

	alpha *= (1.0 - fade_amount);

	return alpha;
}


/* ============================================================
 * FRAGMENT
 * ============================================================
 */

void fragment() {

	vec2 uv = process_uv(UV);

	vec4 tex = texture(TEXTURE, uv);

	vec3 color = process_color(tex.rgb);

	color = process_emission(color);

	float alpha = process_alpha(tex.a, uv);

	COLOR = vec4(color, alpha);
}