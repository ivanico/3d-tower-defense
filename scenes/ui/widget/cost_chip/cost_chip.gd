extends HBoxContainer
class_name CostChip

## One currency readout for a dual-cost upgrade row: icon + amount, tinted red
## when unaffordable. Used twice per upgrade (Base Material chip + the rare
## Tower/Scroll Material chip) by both `meta_row.gd` (Spell Codex) and
## `tower_garage.gd`'s ActionBar — a single shared widget so the icon/label/
## affordability-color logic isn't duplicated at every call site.

const AFFORDABLE_COLOR: Color = Color(0.8, 0.82, 0.9, 1)
const UNAFFORDABLE_COLOR: Color = Color(0.95, 0.35, 0.35, 1)

@onready var icon_rect: TextureRect = $Icon
@onready var amount_label: Label = $Label

func set_cost(amount: int, icon: Texture2D, affordable: bool) -> void:
	icon_rect.texture = icon
	amount_label.text = str(amount)
	amount_label.add_theme_color_override("font_color", AFFORDABLE_COLOR if affordable else UNAFFORDABLE_COLOR)
