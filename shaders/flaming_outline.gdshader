shader_type canvas_item;

/* Godot 4 screen texture replacement */
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

// Donut Mask
uniform vec2 DonutMaskCenter = vec2(0.5);
uniform float DonutMaskSize = 0.5;
uniform float DonutMaskThickness = 0.15;

// Outline
uniform float OutlineWidth : hint_range(0.0, 64) = 3.0;
uniform float OutlinePixelSize : hint_range(0.01, 10.0) = 1.0;

// Rainbow
uniform bool UseRainbowColorOutline = true;
uniform float RainbowColorLightOffset : hint_range(0.0, 1.0) = 0.5;
uniform float RainbowColorSinFrequency : hint_range(0.1, 2.0) = 0.1;

// Noise
uniform bool OutlineUseNoise = false;
uniform float NoiseBlockSize = 5.0;
uniform float NoiseMaxLineWidth = 10.0;
uniform float NoiseMinLineWidth = 5.0;
uniform float NoiseFreq = 1.0;

uniform vec4 BackgroundColor : source_color = vec4(0.95, 0.95, 0.95, 1.0);

// Constants
const int ANGLE_RESOLUTION = 16;
const int GRADIENT_RESOLUTION = 8;

/* ---------------- Mask ---------------- */

float createDonutMask(vec2 pixel_size, vec2 uv) {
	float ratio = pixel_size.x / pixel_size.y;
	vec2 scaledUV = (uv - vec2(DonutMaskCenter.x, 0.0))
		/ vec2(ratio, 1.0) + vec2(DonutMaskCenter.x, 0.0);

	return (1.0 - smoothstep(DonutMaskSize - 0.2, DonutMaskSize,
		length(scaledUV - DonutMaskCenter)))
		* smoothstep(
			DonutMaskSize - DonutMaskThickness - 0.1,
			DonutMaskSize - DonutMaskThickness,
			length(scaledUV - DonutMaskCenter)
		);
}

/* ---------------- Color ---------------- */

vec4 createRainbowColor(float t) {
	return vec4(
		RainbowColorLightOffset + sin(2.0 * PI * RainbowColorSinFrequency * t),
		RainbowColorLightOffset + sin(2.0 * PI * RainbowColorSinFrequency * t + radians(120.0)),
		RainbowColorLightOffset + sin(2.0 * PI * RainbowColorSinFrequency * t + radians(240.0)),
		1.0
	);
}

/* ---------------- Noise Helpers ---------------- */

float hash(vec2 p, float s) {
	return fract(35.1 * sin(dot(vec3(112.3, 459.2, 753.2), vec3(p, s))));
}

float noise(vec2 p, float s) {
	vec2 b = floor(p);
	vec2 f = fract(p);
	return mix(
		mix(hash(b, s), hash(b + vec2(1,0), s), f.x),
		mix(hash(b + vec2(0,1), s), hash(b + vec2(1,1), s), f.x),
		f.y
	);
}

float getLineWidth(vec2 p, float s) {
	p /= NoiseBlockSize;
	float w = 0.0;
	float intensity = 1.0;

	for (int i = 0; i < 3; i++) {
		w = mix(w, noise(p, s), intensity);
		p *= 0.5;
		intensity *= 0.5;
	}

	return mix(NoiseMaxLineWidth, NoiseMinLineWidth, w);
}

/* ---------------- Outline ---------------- */

bool pixelInRange(vec2 uv, vec2 dist) {
	for (int i = 0; i < ANGLE_RESOLUTION; i++) {
		float a = 2.0 * PI * float(i) / float(ANGLE_RESOLUTION);
		vec2 disp = dist * vec2(cos(a), sin(a));
		if (texture(screen_tex, uv + disp).b < 0.5) return true;
	}
	return false;
}

float getClosestDistance(vec2 uv, vec2 maxDist) {
	if (!pixelInRange(uv, maxDist)) return -1.0;

	float hi = 1.0;
	float lo = 0.0;

	for (int i = 0; i < GRADIENT_RESOLUTION; i++) {
		float mid = (hi + lo) * 0.5;
		if (pixelInRange(uv, mid * maxDist)) hi = mid;
		else lo = mid;
	}
	return hi;
}

/* ---------------- Fragment ---------------- */

void fragment() {
	float mask = createDonutMask(TEXTURE_PIXEL_SIZE, UV);

	vec4 outlineColor = UseRainbowColorOutline
		? createRainbowColor(TIME)
		: vec4(1.0, 0.0, 0.0, 1.0);

	vec4 original = texture(screen_tex, SCREEN_UV);
	vec4 color = original;

	/* Inline blending */
	if (color.rgb != BackgroundColor.rgb) {
		color.rgb = mix(outlineColor.rgb, color.rgb,
			1.0 - tanh(3.0 * original.b));
	}

	/* Outline */
	vec2 unit = OutlinePixelSize / vec2(textureSize(screen_tex, 0));
	color.a = 0.0;

	for (float x = -OutlineWidth; x <= OutlineWidth; x++) {
		for (float y = -OutlineWidth; y <= OutlineWidth; y++) {
			vec4 t = texture(screen_tex, SCREEN_UV + vec2(x, y) * unit);
			if (t.rgb == vec3(0.0)) {
				color.a += outlineColor.a / max(x*x + y*y, 1.0);
			}
		}
	}

	/* Noise */
	if (OutlineUseNoise) {
		float step = floor(NoiseFreq * TIME);
		vec2 dist = SCREEN_PIXEL_SIZE * getLineWidth(SCREEN_UV / SCREEN_PIXEL_SIZE, step);
		float w = getClosestDistance(SCREEN_UV, dist);
		if (w > 0.0) color.a *= tanh(5.0 * w);
	}

	color.a *= mask;
	COLOR = color;
}
