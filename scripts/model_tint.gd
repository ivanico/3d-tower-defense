extends RefCounted

## Washes every MeshInstance3D under `root` in `color`, via material_overlay.
## Used for placeholder towers that borrow another tower's model
## (TowerDefinition.model_tint), by both the gameplay tower and the garage
## preview, so the two always look the same. Alpha is the strength; 0 = no-op.
##
## Only MeshInstance3D is touched, so billboards (the HP bar's Sprite3D /
## Label3D) keep their own look. Consumers preload() this (no class_name, same
## reason as scripts/resource_dir.gd).


static func apply(root: Node, color: Color) -> void:
	if color.a <= 0.0:
		return
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = color
	_apply_to(root, mat)


static func _apply_to(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		node.material_overlay = mat
	for child in node.get_children():
		_apply_to(child, mat)
