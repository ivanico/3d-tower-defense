extends HBoxContainer
class_name CostChip

## One currency readout for a dual-cost upgrade row: icon + amount, tinted red
## when unaffordable. Used twice per upgrade (Base Material chip + the rare
## Tower/Scroll Material chip) by both `meta_row.gd` (Spell Codex) and
## `tower_garage.gd`'s ActionBar — a single shared widget so the icon/label/
## affordability-color logic isn't duplicated at every call site.

const AFFORDABLE_COLOR: Color = Color(0.8, 0.82, 0.9, 1)
const UNAFFORDABLE_COLOR: Color = Color(0.95, 0.35, 0.35, 1)

## Sentinel for `set_cost`'s `owned` argument: show the cost alone, exactly as
## this chip did before any balance was displayed. `meta_row.gd` (Spell Codex)
## still calls the three-argument form and is unchanged by it.
const OWNED_HIDDEN: int = -1

@onready var icon_rect: TextureRect = $Icon
@onready var amount_label: Label = $Label

## `owned` reads "have / need" — the balance first, then the price, the order a
## crafting cost is read in. The affordability tint still colours the whole
## readout, so a shortfall is one red chip rather than two digits to compare.
func set_cost(amount: int, icon: Texture2D, affordable: bool, owned: int = OWNED_HIDDEN) -> void:
	icon_rect.texture = icon
	amount_label.text = str(amount) if owned == OWNED_HIDDEN else "%d/%d" % [owned, amount]
	amount_label.add_theme_color_override("font_color", AFFORDABLE_COLOR if affordable else UNAFFORDABLE_COLOR)

## Balance only, never red — there is no cost to fall short of. The garage uses
## this at max star, where nothing is left to buy but what you hold is still
## worth seeing.
func set_balance(amount: int, icon: Texture2D) -> void:
	icon_rect.texture = icon
	amount_label.text = str(amount)
	amount_label.add_theme_color_override("font_color", AFFORDABLE_COLOR)
