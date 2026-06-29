shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

uniform vec4 color_1 : source_color = vec4(0.60, 0.78, 0.24, 1.0);
uniform vec4 color_2 : source_color = vec4(0.66, 0.82, 0.28, 1.0);
uniform vec4 color_3 : source_color = vec4(0.70, 0.85, 0.34, 1.0);
uniform vec4 color_4 : source_color = vec4(0.56, 0.74, 0.22, 1.0);
uniform float tiles_x : hint_range(1.0, 100.0) = 40.0;
uniform float tiles_z : hint_range(1.0, 100.0) = 40.0;

void fragment() {
	vec2 uv = floor(UV * vec2(tiles_x, tiles_z));
	int xi = int(mod(uv.x, 2.0));
	int yi = int(mod(uv.y, 2.0));
	int idx = xi + yi * 2; // 0,1,2,3 in a fixed repeating 2x2 block, never random

	vec3 col;
	if (idx == 0) {
		col = color_1.rgb;
	} else if (idx == 1) {
		col = color_2.rgb;
	} else if (idx == 2) {
		col = color_3.rgb;
	} else {
		col = color_4.rgb;
	}

	ALBEDO = col;
	ROUGHNESS = 0.9;
	METALLIC = 0.0;
}