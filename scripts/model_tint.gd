extends RefCounted

## Washes every MeshInstance3D under `root` in `color`, via material_overlay.
## Used for placeholder towers and enemies that borrow another model
## (TowerDefinition.model_tint / EnemyDefinition.model_tint), by the gameplay
## tower, the garage preview and enemy.gd, so they always look the same. Alpha
## is the strength; 0 = no-op.
##
## Only MeshInstance3D is touched, so billboards (the HP bar's Sprite3D /
## Label3D) keep their own look. Consumers preload() this (no class_name, same
## reason as scripts/resource_dir.gd).
##
## A mesh has ONE material_overlay slot, which HitFlashComponent also uses.
## Both go through add_overlay(), which chains the two with next_pass instead
## of one replacing the other, in whichever order they arrive.


static func apply(root: Node, color: Color) -> void:
	if color.a <= 0.0:
		return
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = color
	_apply_to(root, mat)


## Adds `mat` to `mesh`'s overlay pass, keeping any overlay already there.
## on_top = true draws `mat` after the existing one (the hit flash must show
## over a tint); false draws it underneath. Handles two layers (tint + flash),
## which is all the project uses. The material that gets a next_pass is always
## a per-mesh copy, so a tint shared by sibling meshes is never altered, and an
## on_top material is never copied (HitFlashComponent tweens its own instance).
static func add_overlay(mesh: MeshInstance3D, mat: Material, on_top: bool = false) -> void:
	var existing := mesh.material_overlay
	if existing == null:
		mesh.material_overlay = mat
		return
	var lower: Material = existing.duplicate() if on_top else mat.duplicate()
	lower.next_pass = mat if on_top else existing
	mesh.material_overlay = lower


static func _apply_to(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		add_overlay(node, mat)
	for child in node.get_children():
		_apply_to(child, mat)
