shader_type spatial;
render_mode unshaded, blend_mix;

// Used as MeshInstance3D.material_overlay by HitFlashComponent -- an
// overlay is a second, independent render pass drawn on top of whatever
// the mesh's own material already rendered. It never reads or writes that
// base material, so animating flash_amount here can't discolor the model.
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	ALBEDO = vec3(1.0);
	ALPHA = flash_amount;
}
