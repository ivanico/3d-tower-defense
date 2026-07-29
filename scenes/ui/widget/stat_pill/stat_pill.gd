@tool
extends "res://scenes/ui/widget/pill_base.gd"

## One garage stat readout: LEVEL / ATK / HP. A title above a rounded pill holding
## the current value and, in green, what the next star adds — with the stat's icon
## standing proud of the pill's left end, exactly like the top bar's currency pills.
##
## The pill is a StyleBoxFlat built here, NOT a piece of art: it is a plain rounded
## rectangle, so its colour and radius are knobs and there is no PNG to keep in
## step with the palette. The shape and the icon overhang come from `pill_base.gd`,
## which the currency pills share.

@export_group("Content")
## The small label above the pill. Set per instance — "LEVEL", "ATK", "HP".
@export var title: String = "ATK":
	set(value):
		title = value
		_apply()

## The current value. A String, not an int, because LEVEL reads "3/5".
@export var value_text: String = "20":
	set(value):
		value_text = value
		_apply()

## What the next star adds, already formatted — "(+2)". Empty hides it, which is
## what a maxed stat wants; "+0" would be noise.
@export var delta_text: String = "":
	set(value):
		delta_text = value
		_apply()

@export_group("Pill look")
@export var pill_color: Color = Color(0.10, 0.05, 0.18, 0.55):
	set(value):
		pill_color = value
		_apply()

## Softly rounded, NOT a capsule — the reference's stat pills are rounded
## rectangles. Half the pill height would give a full capsule; 0 gives square.
@export var corner_radius: int = 10:
	set(value):
		corner_radius = maxi(value, 0)
		_apply()

@export_group("Text")
@export var title_height: int = 25:
	set(value):
		title_height = maxi(value, 0)
		_apply()

@export var title_font_size: int = 20:
	set(value):
		title_font_size = maxi(value, 1)
		_apply()

@export var title_color: Color = Color(0.85, 0.8, 0.95):
	set(value):
		title_color = value
		_apply()

@export var value_font_size: int = 30:
	set(value):
		value_font_size = maxi(value, 1)
		_apply()

@export var delta_font_size: int = 24:
	set(value):
		delta_font_size = maxi(value, 1)
		_apply()

@export var delta_color: Color = Color(0.35, 0.92, 0.4):
	set(value):
		delta_color = value
		_apply()

## Gap between the overhanging icon and where the text may start.
@export var text_gap: int = 8:
	set(value):
		text_gap = maxi(value, 0)
		_apply()


## The title sits ABOVE the pill rather than inside it, as in the reference, so the
## widget needs that much extra height and the pill has to start below it.
func _header_height() -> int:
	return title_height


func _apply_content() -> void:
	var pill: PanelContainer = get_node_or_null("Pill")
	var title_label: Label = get_node_or_null("Title")
	var value_label: Label = get_node_or_null("Pill/Line/Value")
	var delta_label: Label = get_node_or_null("Pill/Line/Delta")
	if pill == null or title_label == null or value_label == null or delta_label == null:
		return

	var box := StyleBoxFlat.new()
	box.bg_color = pill_color
	box.corner_radius_top_left = corner_radius
	box.corner_radius_top_right = corner_radius
	box.corner_radius_bottom_left = corner_radius
	box.corner_radius_bottom_right = corner_radius
	# Content margins, not theme constants: a PanelContainer insets its child by the
	# panel StyleBox and ignores margin_* constants entirely. This is what keeps the
	# value clear of the icon overhanging the pill's left end.
	box.content_margin_left = icon_overlap + text_gap
	box.content_margin_right = text_gap
	pill.add_theme_stylebox_override("panel", box)

	# Starts exactly where the VALUE starts, so title and number share a left edge
	# just clear of the overhanging icon — the arrangement in the reference.
	var text_left: float = float(icon_size) + text_gap
	title_label.position = Vector2(text_left, 0.0)
	title_label.size = Vector2(pill_size.x - icon_overlap - text_gap, title_height)
	title_label.add_theme_font_size_override("font_size", title_font_size)
	title_label.add_theme_color_override("font_color", title_color)
	title_label.text = title

	value_label.add_theme_font_size_override("font_size", value_font_size)
	value_label.text = value_text

	delta_label.add_theme_font_size_override("font_size", delta_font_size)
	delta_label.add_theme_color_override("font_color", delta_color)
	delta_label.text = delta_text
	delta_label.visible = not delta_text.is_empty()


## The generated stylebox and font overrides are built fresh every layout pass, so
## a copy baked into the garage scene would be a stale override of the knobs above.
## See the same guard in tower_slot.gd and nav_button.gd.
func _validate_property(property: Dictionary) -> void:
	super(property)
	if property.name.begins_with("theme_override_"):
		property.usage &= ~PROPERTY_USAGE_STORAGE
