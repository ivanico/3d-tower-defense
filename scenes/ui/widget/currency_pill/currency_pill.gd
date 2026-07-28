@tool
class_name CurrencyPill
extends Control

## One top-bar currency readout: a dark pill holding the amount, with the currency
## icon sitting ON the pill's left end and overhanging it above and below.
##
## The icon is deliberately NOT inside the pill's layout. It is a sibling drawn on
## top of it, which is the only way it can be taller than the pill — that overhang
## is the whole look. The amount text carries a left margin big enough to clear it.
##
## Everything below is editable in the inspector and updates live.

## Size of the dark pill itself, in pixels. The widget is wider than this by
## however much of the icon hangs off to the left.
@export var pill_size: Vector2i = Vector2i(190, 90):
	set(value):
		pill_size = Vector2i(maxi(value.x, 8), maxi(value.y, 8))
		_apply()

## Width/height of the square currency icon. Keep it LARGER than `pill_size.y` —
## the icon standing proud of the pill is the point.
@export var icon_size: int = 124:
	set(value):
		icon_size = maxi(value, 8)
		_apply()

## Per-instance fine-tune for how big the ART inside the icon reads.
##
## The icon PNGs are all 1254x1254 but their artwork fills different amounts of
## that canvas — the energy bolt is 595x840 (47% wide, 67% tall) while the
## materials gem is 720x705 (57% wide, 56% tall). At the same node size the gem
## therefore draws 20% wider and looks like the bigger icon even though the two
## cover almost the same area. This scales the drawn icon inside its slot without
## moving the pill, so a row of icons can be made to read as one size.
@export var icon_scale: float = 1.0:
	set(value):
		icon_scale = clampf(value, 0.05, 4.0)
		_apply()

## Free nudge for the icon, in pixels, on top of wherever the layout puts it.
## Positive x moves it right, positive y moves it DOWN. Use this to fine-tune art
## that is not centred inside its own canvas; it does not move the pill.
@export var icon_offset: Vector2 = Vector2.ZERO:
	set(value):
		icon_offset = value
		_apply()

## How many pixels of the icon sit on top of the pill; the rest hangs off the left.
@export var icon_overlap: int = 62:
	set(value):
		icon_overlap = maxi(value, 0)
		_apply()

## Extra gap between the icon and where the amount text may start.
@export var text_gap: int = 10:
	set(value):
		text_gap = maxi(value, 0)
		_apply()

## Size of the amount text.
@export var font_size: int = 40:
	set(value):
		font_size = maxi(value, 1)
		_apply()

## The currency icon. Set per instance — energy, materials, and so on.
@export var icon: Texture2D:
	set(value):
		icon = value
		_apply()

## The number shown. Screens normally drive this through `set_amount()`.
@export var amount: int = 0:
	set(value):
		amount = value
		_apply()


func _ready() -> void:
	_apply()


func set_amount(value: int) -> void:
	amount = value


func _apply() -> void:
	# Property setters fire during scene deserialization, before children exist.
	if not is_inside_tree():
		return
	var pill: PanelContainer = get_node_or_null("Pill")
	var label: Label = get_node_or_null("Pill/AmountLabel")
	var icon_rect: TextureRect = get_node_or_null("Icon")
	if pill == null or label == null or icon_rect == null:
		return

	# The pill begins where the icon stops overlapping it.
	var pill_x: float = float(icon_size - icon_overlap)
	var height: int = maxi(icon_size, pill_size.y)
	custom_minimum_size = Vector2(pill_x + pill_size.x, height)

	pill.position = Vector2(pill_x, (height - pill_size.y) * 0.5)
	pill.custom_minimum_size = Vector2(pill_size)
	pill.size = Vector2(pill_size)

	# Push the text clear of the overlapping icon, then centre it in what is left
	# so a 1-digit and a 4-digit amount both sit sensibly.
	pill.add_theme_constant_override("margin_left", icon_overlap + text_gap)
	pill.add_theme_constant_override("margin_right", text_gap)
	label.add_theme_font_size_override("font_size", font_size)
	label.text = str(amount)

	# The LAYOUT slot stays `icon_size` so the pill never shifts; `icon_scale` only
	# changes how big the icon is drawn inside that slot, centred on it.
	icon_rect.texture = icon
	var drawn: float = icon_size * icon_scale
	icon_rect.custom_minimum_size = Vector2(drawn, drawn)
	icon_rect.size = Vector2(drawn, drawn)
	icon_rect.position = Vector2(
			(icon_size - drawn) * 0.5, (height - drawn) * 0.5) + icon_offset


## Layout the script computes must never be serialised into a scene that instances
## this widget, or the stale baked copy overrides the knobs above.
func _validate_property(property: Dictionary) -> void:
	if property.name in ["size", "custom_minimum_size"]:
		property.usage &= ~PROPERTY_USAGE_STORAGE
