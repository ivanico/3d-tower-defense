shader_type spatial;
// Tower shield bubble (09-13): almost clear in the middle, brighter at the
// edge (fresnel), so it reads as a glass dome without hiding the tower.
render_mode unshaded, blend_mix, cull_back, depth_draw_never;

uniform vec4 color : source_color = vec4(0.55, 0.85, 1.0, 1.0);
uniform float base_alpha : hint_range(0.0, 1.0) = 0.10;
uniform float rim_alpha : hint_range(0.0, 1.0) = 0.65;
uniform float rim_power : hint_range(0.5, 8.0) = 2.5;

void fragment() {
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);
	ALBEDO = color.rgb;
	ALPHA = clamp(base_alpha + rim * rim_alpha, 0.0, 1.0);
}
