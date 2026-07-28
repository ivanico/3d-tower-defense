@tool
class_name PlayButton
extends Button

## The big Play button on the world map. Two lines: the word on top, the energy
## cost underneath as an icon plus "xN".
##
## `ui_play_button_v3.png` is 1905x825 with a thick ornate gold frame. Two rules
## from components.md apply and are why the knobs below exist:
##   - the frame CANNOT be 9-sliced (it is far too heavy), so the whole image
##     stretches — which means `button_size` must keep the art's 2.31 aspect or
##     the gold corners visibly distort
##   - content therefore has to sit inside the art's interior rect, hence the
##     margin knobs. Defaults are measured off the blue panel in the source art.

const ART_ASPECT := 1905.0 / 825.0

## On-screen size. Width is the knob you want; height follows the art's aspect so
## the frame never distorts. Set `lock_aspect` false if you really want to squash it.
@export var button_width: int = 600:
	set(value):
		button_width = maxi(value, 32)
		_apply()

## Height, recomputed from `button_width` whenever `lock_aspect` is on.
@export var button_height: int = 260:
	set(value):
		button_height = maxi(value, 16)
		_apply()

## Keep the art's 2.31 width:height ratio. Turning this off distorts the gold frame.
@export var lock_aspect: bool = true:
	set(value):
		lock_aspect = value
		_apply()

## Inset from each edge to the art's interior, as a FRACTION of the button size.
## Content outside this lands on the gold frame.
##
## MEASURED off `ui_play_button_v3.png`, not estimated: its blue panel occupies
## x 152..1735 and y 154..627 of 1905x825, i.e. left 0.080, right 0.089, top 0.187,
## bottom 0.240. The defaults below are those numbers rounded outward slightly.
## The interior is only ~57% of the button's height, so the two text lines have
## about 145px to live in on a 260px-tall button — that is why `play_font_size`
## and `cost_icon_size` cannot both be large.
@export var margin_h: float = 0.09:
	set(value):
		margin_h = clampf(value, 0.0, 0.45)
		_apply()

@export var margin_top: float = 0.19:
	set(value):
		margin_top = clampf(value, 0.0, 0.45)
		_apply()

@export var margin_bottom: float = 0.25:
	set(value):
		margin_bottom = clampf(value, 0.0, 0.45)
		_apply()

## Vertical space between the PLAY line and the cost line, in pixels.
@export var line_gap: int = 0:
	set(value):
		line_gap = maxi(value, 0)
		_apply()

## Free nudge for BOTH lines together, in pixels. Positive y moves them DOWN.
## Use this rather than fighting the margins when the text sits a few pixels off.
@export var content_offset: Vector2 = Vector2.ZERO:
	set(value):
		content_offset = value
		_apply()

## Top line.
@export var play_text: String = "PLAY":
	set(value):
		play_text = value
		_apply()

@export var play_font_size: int = 58:
	set(value):
		play_font_size = maxi(value, 1)
		_apply()

## Bottom line: the energy icon and how many it costs to start a run.
@export var cost_icon: Texture2D:
	set(value):
		cost_icon = value
		_apply()

@export var cost_amount: int = 1:
	set(value):
		cost_amount = value
		_apply()

@export var cost_font_size: int = 40:
	set(value):
		cost_font_size = maxi(value, 1)
		_apply()

@export var cost_icon_size: int = 72:
	set(value):
		cost_icon_size = maxi(value, 4)
		_apply()


## Guards the re-entry in `_apply()` where locking the aspect writes back to
## `button_height`, whose setter calls `_apply()` again. Without this it recurses
## until the stack blows.
var _applying: bool = false


func _ready() -> void:
	_apply()


func _apply() -> void:
	if not is_inside_tree() or _applying:
		return
	_applying = true
	var box: VBoxContainer = get_node_or_null("Content")
	var play_label: Label = get_node_or_null("Content/PlayLabel")
	var cost_row: HBoxContainer = get_node_or_null("Content/CostRow")
	var cost_icon_rect: TextureRect = get_node_or_null("Content/CostRow/Icon")
	var cost_label: Label = get_node_or_null("Content/CostRow/Amount")
	if box == null or play_label == null or cost_row == null:
		_applying = false
		return

	if lock_aspect:
		button_height = int(round(button_width / ART_ASPECT))
	custom_minimum_size = Vector2(button_width, button_height)

	# Pull the content box inside the ornate frame, then apply the free nudge.
	box.offset_left = button_width * margin_h + content_offset.x
	box.offset_right = -button_width * margin_h + content_offset.x
	box.offset_top = button_height * margin_top + content_offset.y
	box.offset_bottom = -button_height * margin_bottom + content_offset.y
	box.add_theme_constant_override("separation", line_gap)

	play_label.text = play_text
	play_label.add_theme_font_size_override("font_size", play_font_size)

	cost_icon_rect.texture = cost_icon
	cost_icon_rect.custom_minimum_size = Vector2(cost_icon_size, cost_icon_size)
	cost_label.text = "x%d" % cost_amount
	cost_label.add_theme_font_size_override("font_size", cost_font_size)
	_applying = false


func _validate_property(property: Dictionary) -> void:
	if property.name in ["custom_minimum_size", "size"]:
		property.usage &= ~PROPERTY_USAGE_STORAGE
