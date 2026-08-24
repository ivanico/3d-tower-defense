shader_type canvas_item;

// Rounds off the icon's corners regardless of what the source PNG's own
// corners look like. Several spell/upgrade icons (e.g.
// assets/ui/spells/fire/icon_spell_bolt_fire.png) bake a fully OPAQUE BLACK
// square behind their own rounded internal frame -- rendering them edge to
// edge in a TextureRect (as draft cards do, to fill the icon slot) shows
// those black corner triangles against the card's lighter background.
// Clipping to a rounded rect here hides that regardless of which icon is
// assigned, without needing to touch/re-export any of the icon art.

uniform float corner_radius : hint_range(0.0, 100.0) = 20.0;
uniform vec2 rect_size = vec2(170.0, 170.0);

void fragment() {
	vec2 pixel_pos = UV * rect_size;
	vec2 half_size = rect_size * 0.5;
	vec2 d = abs(pixel_pos - half_size) - (half_size - corner_radius);
	float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - corner_radius;
	COLOR = texture(TEXTURE, UV);
	COLOR.a *= 1.0 - smoothstep(-1.5, 1.5, dist);
}
