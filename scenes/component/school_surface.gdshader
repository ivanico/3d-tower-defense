shader_type spatial;
render_mode blend_mix, cull_back, diffuse_burley, specular_schlick_ggx;

// One shared "elemental surface" shader for every spell school -- looks
// differ by the uniform PRESET each SchoolVFXComponent instance feeds in
// (see school_vfx_component.gd::PRESETS), not by five separate shader
// files. Procedural noise (value_noise below), not a texture asset -- same
// "generate, don't depend on art" philosophy as bar_texture.gd.

uniform vec4 albedo_color : source_color = vec4(1.0);
uniform vec4 emission_color : source_color = vec4(1.0);
uniform float emission_energy : hint_range(0.0, 8.0) = 1.5;
uniform vec2 noise_scroll = vec2(0.3, 0.5);
uniform float noise_scale : hint_range(1.0, 32.0) = 8.0;
uniform float noise_strength : hint_range(0.0, 1.0) = 0.35;
uniform float fresnel_power : hint_range(0.5, 8.0) = 3.0;
uniform float fresnel_strength : hint_range(0.0, 2.0) = 0.6;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.15;
// Shifts the surface between albedo_color/emission_color and this second
// tone -- 0 strength (every school's default) is a pure no-op, identical to
// before. tone_source picks WHERE the blend factor comes from:
//   0 = the scrolling noise field (animated, drifts over time -- Fire)
//   1 = raw fresnel/view angle (static -- center of the sphere stays one
//       color, the rim stays the other, and neither moves on its own since
//       it's driven by geometry, not TIME -- Frost)
uniform vec4 tone_color : source_color = vec4(1.0);
uniform float tone_strength : hint_range(0.0, 1.0) = 0.0;
uniform int tone_source = 0;
// tone_use_threshold = false (default, every school's prior behavior,
// unchanged): the blend factor is used raw/linear, spreading the transition
// smoothly across the whole surface. true: smoothstep concentrates the
// transition into a narrow band around tone_threshold instead, so it reads
// as two clear, mostly-solid regions (e.g. "a white ball with a distinct
// blue outer band") instead of one continuous gradient.
uniform bool tone_use_threshold = false;
uniform float tone_threshold : hint_range(0.0, 1.0) = 0.5;
uniform float tone_softness : hint_range(0.01, 1.0) = 0.5;

// Object-space position, passed from vertex() where VERTEX IS object space
// by default -- in fragment() it's view space instead (Godot docs), which
// would make the noise pattern swim with the object's own movement through
// the camera view instead of staying glued to its surface.
varying vec3 model_vertex;

void vertex() {
	model_vertex = VERTEX;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// Cheap bilinear value noise -- four hashed corners of the UV cell, smoothed.
float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void fragment() {
	// model_vertex, NOT UV -- a sphere's UV mapping has a seam where U wraps
	// from 1.0 back to 0.0 (plus pinching at the poles), so noise sampled
	// from UV jumps discontinuously right at that seam, which is exactly
	// what read as a hard "split" cutting across the ball instead of one
	// continuous pattern. Object-space position has no wraparound anywhere
	// on the sphere, so the same noise field is seamless all the way around.
	vec2 uv = model_vertex.xz * noise_scale + TIME * noise_scroll;
	float n = value_noise(uv);
	// Raw (un-scaled by fresnel_strength) rim term -- 0 dead center facing
	// the camera, 1 at the grazing silhouette edge. Computed once, shared by
	// the tone blend below AND the emission rim-brighten further down.
	float raw_fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);

	// tone_strength = 0 (most schools) makes this an exact no-op -- mix(x, y,
	// 0.0) always returns x, so albedo_color/emission_color pass through
	// unchanged regardless of the factor. At tone_strength > 0, tone_source
	// picks whether the shift is driven by the scrolling noise (animated,
	// cycles over time) or by raw_fresnel (static, center vs. rim -- reads
	// as one color in the middle of the ball and the other at its edge,
	// with nothing drifting or scrolling since it's tied to view angle, not
	// TIME).
	float tone_raw = tone_source == 1 ? raw_fresnel : n;
	float tone_shaped = tone_use_threshold
		? smoothstep(tone_threshold - tone_softness, tone_threshold + tone_softness, tone_raw)
		: tone_raw;
	float tone_factor = tone_shaped * tone_strength;
	vec3 base_albedo = mix(albedo_color.rgb, tone_color.rgb, tone_factor);
	vec3 base_emission = mix(emission_color.rgb, tone_color.rgb, tone_factor);
	ALBEDO = base_albedo;

	float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_strength;
	vec3 glow = base_emission * emission_energy * pulse;
	// Noise darkens/brightens patches of the surface instead of a flat glow
	// -- this alone is most of what reads as "alive" vs. a solid tinted ball.
	glow *= mix(1.0 - noise_strength, 1.0, n);

	// Rim brighten -- reads as an icy/void edge glow depending on the preset.
	glow += base_emission * (raw_fresnel * fresnel_strength);

	EMISSION = glow;
}
