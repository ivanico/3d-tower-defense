@tool
extends Control

## Shared shape for every "pill with an icon standing proud of its left end" —
## the top bar's currency readouts (`currency_pill`) and the garage's stat chips
## (`stat_pill`).
##
## The icon is deliberately NOT inside the pill's layout. It is a sibling drawn on
## top of it, which is the only way it can be taller than the pill — that overhang
## is the whole look. The scene must therefore provide a `Pill` node and an `Icon`
## TextureRect, with `Icon` declared LAST so it paints over the pill.
##
## This owns the geometry only. What goes inside the pill belongs to the subclass:
## override `_apply_content()`. A subclass that needs room above the pill (a title
## sitting outside it) overrides `_header_height()`.

## Size of the pill itself, in pixels. The widget is wider than this by however
## much of the icon hangs off to the left, and taller by `_header_height()`.
@export var pill_size: Vector2i = Vector2i(190, 90):
	set(value):
		pill_size = Vector2i(maxi(value.x, 8), maxi(value.y, 8))
		_apply()

## Width/height of the square icon. Keep it LARGER than `pill_size.y` — the icon
## standing proud of the pill is the point.
@export var icon_size: int = 124:
	set(value):
		icon_size = maxi(value, 8)
		_apply()

## Per-instance fine-tune for how big the ART inside the icon reads.
##
## The icon PNGs are all ~1254x1254 but their artwork fills different amounts of
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
## Positive x moves it right, positive y moves it DOWN. Use this for art that is
## not centred inside its own canvas; it does not move the pill.
@export var icon_offset: Vector2 = Vector2.ZERO:
	set(value):
		icon_offset = value
		_apply()

## Tilts the icon, in degrees, about its own centre. Layout is unaffected — the
## pill is still placed from the upright slot — so this is free to use on art that
## reads better at an angle, like the garage's sword. Positive is clockwise.
##
## This works only because the icon is a direct child of a plain Control: a
## Container would reset it (see "A Container silently un-rotates its children" in
## ui_tuning.md).
@export var icon_rotation_deg: float = 0.0:
	set(value):
		icon_rotation_deg = value
		_apply()

## How many pixels of the icon sit on top of the pill; the rest hangs off the left.
@export var icon_overlap: int = 62:
	set(value):
		icon_overlap = maxi(value, 0)
		_apply()

## The icon. Set per instance — energy, materials, ATK, HP, and so on.
@export var icon: Texture2D:
	set(value):
		icon = value
		_apply()


func _ready() -> void:
	_apply()


func _apply() -> void:
	# Property setters fire during scene deserialization, before children exist.
	if not is_inside_tree():
		return
	var pill: Control = get_node_or_null("Pill")
	var icon_rect: TextureRect = get_node_or_null("Icon")
	if pill == null or icon_rect == null:
		return

	# The pill begins where the icon stops overlapping it.
	var pill_x: float = float(icon_size - icon_overlap)
	var header: int = _header_height()
	var band: int = maxi(icon_size, pill_size.y)
	custom_minimum_size = Vector2(pill_x + pill_size.x, header + band)

	pill.position = Vector2(pill_x, header + (band - pill_size.y) * 0.5)
	pill.custom_minimum_size = Vector2(pill_size)
	pill.size = Vector2(pill_size)

	# The LAYOUT slot stays `icon_size` so the pill never shifts; `icon_scale` only
	# changes how big the icon is drawn inside that slot, centred on it.
	icon_rect.texture = icon
	icon_rect.visible = icon != null
	var drawn: float = icon_size * icon_scale
	icon_rect.custom_minimum_size = Vector2(drawn, drawn)
	icon_rect.size = Vector2(drawn, drawn)
	icon_rect.position = Vector2(
			(icon_size - drawn) * 0.5,
			header + (band - drawn) * 0.5) + icon_offset
	icon_rect.pivot_offset = Vector2(drawn, drawn) * 0.5
	icon_rect.rotation = deg_to_rad(icon_rotation_deg)

	_apply_content()


## Room reserved ABOVE the pill, for a subclass that puts a title outside it.
func _header_height() -> int:
	return 0


## Fill the pill in. Called at the end of every layout pass.
func _apply_content() -> void:
	pass


## Layout the script computes must never be serialised into a scene that instances
## this widget, or the stale baked copy overrides the knobs above.
func _validate_property(property: Dictionary) -> void:
	if property.name in ["size", "custom_minimum_size"]:
		property.usage &= ~PROPERTY_USAGE_STORAGE
