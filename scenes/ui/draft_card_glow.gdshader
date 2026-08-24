shader_type canvas_item;

// Soft rarity-colored outer glow around the card's rounded silhouette.
// Same rounded-rect SDF as draft_card_icon_mask.gdshader, but instead of
// masking a texture it's used to fade a solid glow_color OUT from the
// card's edge — StyleBoxFlat's built-in "shadow" was tried first, but that
// draws a hard-edged SOLID duplicate of the box shape (no blur), which just
// painted over the card art instead of glowing around it.
//
// This node's rect must be padded by glow_radius on every side beyond the
// card's own visible frame (card_size) — GDScript keeps card_size/
// corner_radius/glow_radius/glow_color in sync via set_shader_parameter.

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec2 card_size = vec2(249.0, 566.0);
// Matches the card art's OWN corner rounding (measured off the source
// texture's actual pixels: ~26px at its native 1054px width, scaled down to
// this card's rendered size) — a bigger radius here than the real card's
// makes the glow ring visibly gap away from the real (sharper) corner while
// still tracking tight on the straight edges.
uniform float corner_radius : hint_range(0.0, 200.0) = 10.0;
uniform float glow_radius : hint_range(1.0, 200.0) = 12.0;

void fragment() {
	vec2 node_size = card_size + vec2(glow_radius * 2.0);
	vec2 pixel_pos = UV * node_size - vec2(glow_radius);
	vec2 half_size = card_size * 0.5;
	vec2 d = abs(pixel_pos - half_size) - (half_size - corner_radius);
	float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - corner_radius;
	// 0 deep inside the card (so the card's own art shows through
	// untouched), ramps to full brightness right at the edge, then decays
	// exponentially out to glow_radius px beyond it. An exponential decay
	// (bright at the source, tapering off immediately with a long soft
	// tail) reads as a soft haze; a smoothstep ease here instead held near-
	// full brightness close to the edge and dropped fast through the
	// middle, which read as a hard-edged ring rather than a fade.
	float inner = smoothstep(-4.0, 0.0, dist);
	float outer = exp(-2.0 * max(dist, 0.0) / glow_radius) * step(dist, glow_radius);
	float alpha = inner * outer;
	COLOR = glow_color;
	COLOR.a *= alpha;
}
