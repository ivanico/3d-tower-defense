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
	ALBEDO = albedo_color.rgb;

	vec2 uv = UV * noise_scale + TIME * noise_scroll;
	float n = value_noise(uv);

	float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_strength;
	vec3 glow = emission_color.rgb * emission_energy * pulse;
	// Noise darkens/brightens patches of the surface instead of a flat glow
	// -- this alone is most of what reads as "alive" vs. a solid tinted ball.
	glow *= mix(1.0 - noise_strength, 1.0, n);

	// Rim brighten -- reads as an icy/void edge glow depending on the preset.
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power) * fresnel_strength;
	glow += emission_color.rgb * fresnel;

	EMISSION = glow;
}
