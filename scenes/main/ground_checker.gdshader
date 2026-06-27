shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

uniform vec4 color_a : source_color = vec4(0.15, 0.55, 0.15, 1.0);
uniform vec4 color_b : source_color = vec4(0.28, 0.75, 0.28, 1.0);
uniform float tiles_x : hint_range(1.0, 100.0) = 40.0;
uniform float tiles_z : hint_range(1.0, 100.0) = 40.0;

void fragment() {
	vec2 uv = floor(UV * vec2(tiles_x, tiles_z));
	float checker = mod(uv.x + uv.y, 2.0);
	ALBEDO = mix(color_a.rgb, color_b.rgb, checker);
	ROUGHNESS = 0.9;
	METALLIC = 0.0;
}
