shader_type canvas_item;

// Desaturates a locked tower's icon so no grey copy of the art has to exist.
// `modulate` alone cannot do this — it can only tint or darken, never remove hue.
//
// COLOR arrives already set to the texture colour multiplied by the node's
// modulate, so reading and rewriting it in place preserves both alpha and any
// modulate the slot applies on top.

// 0 = untouched artwork, 1 = fully grey.
uniform float amount : hint_range(0.0, 1.0) = 1.0;
// Below 1 darkens the greyed art so it reads as unavailable rather than washed out.
uniform float brightness : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	// Rec. 709 luma: green carries most perceived brightness, so a flat average
	// would make green icons too light and blue ones too dark.
	float luma = dot(COLOR.rgb, vec3(0.2126, 0.7152, 0.0722));
	COLOR.rgb = mix(COLOR.rgb, vec3(luma), amount) * mix(1.0, brightness, amount);
}
