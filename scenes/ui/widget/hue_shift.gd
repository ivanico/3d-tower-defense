extends RefCounted

## Puts `hue_shift.gdshader` on a CanvasItem, or takes it off at 0. Shared by
## pill_base.gd (`icon_hue_shift`) and store_item_card.gd (an item's
## `icon_hue_shift`), so placeholder icons can borrow other art in a different
## colour in one way only.

const SHADER := preload("res://scenes/ui/widget/hue_shift.gdshader")


## No material at all at 0, so every unshifted item draws exactly as before.
static func apply(item: CanvasItem, amount: float) -> void:
	if is_zero_approx(amount):
		item.material = null
		return
	var mat := item.material as ShaderMaterial
	if mat == null or mat.shader != SHADER:
		mat = ShaderMaterial.new()
		mat.shader = SHADER
		item.material = mat
	mat.set_shader_parameter("hue_shift", amount)
