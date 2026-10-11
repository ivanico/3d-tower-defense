@tool
extends Button

## The red notification badge, shared by every button that can show one: the
## bottom nav tiles (`nav_button`) and the home screen's side buttons
## (`home_side_button`, 10-02). One copy of the badge knobs and placement.
##
## Subclasses build their own content, call `_build_badge()` LAST (creation order
## is paint order, so the badge lands on top), and finish their `_layout()` with
## `_layout_badge()`. The badge is an INTERNAL child, never written into a .tscn.

const BADGE_TEXTURE := preload("res://assets/ui/common/ui_notification_badge.png")

@export_group("Badge")
## Show the little red notification badge on this button.
@export var badge_visible: bool = false:
	set(value):
		badge_visible = value
		_layout()

## Number or text inside the badge. Leave empty for a plain dot.
@export var badge_text: String = "":
	set(value):
		badge_text = value
		if _badge_label != null:
			_badge_label.text = value

## Badge size in pixels (square).
@export var badge_size: int = 52:
	set(value):
		badge_size = maxi(value, 4)
		_layout()

## Which corner of the button the badge sits in, as a fraction: (0,0) top-left,
## (1,0) top-right, (0.5,0.5) dead centre.
@export var badge_anchor: Vector2 = Vector2(1, 0):
	set(value):
		badge_anchor = value
		_layout()

## Free pixel nudge on top of `badge_anchor`. Positive y moves it DOWN.
@export var badge_offset: Vector2 = Vector2.ZERO:
	set(value):
		badge_offset = value
		_layout()
@export_group("")

var _badge: TextureRect
var _badge_label: Label


func _build_badge() -> void:
	if _badge != null:
		return
	_badge = TextureRect.new()
	_badge.name = "Badge"
	_badge.texture = BADGE_TEXTURE
	_badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_badge, false, Node.INTERNAL_MODE_BACK)

	_badge_label = Label.new()
	_badge_label.name = "BadgeLabel"
	_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_badge_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge_label.text = badge_text
	_badge.add_child(_badge_label, false, Node.INTERNAL_MODE_BACK)


## Override, and end it with `_layout_badge()`.
func _layout() -> void:
	_layout_badge()


func _layout_badge() -> void:
	if _badge == null:
		return
	_badge.visible = badge_visible
	if badge_visible:
		var badge := Vector2(badge_size, badge_size)
		_badge.size = badge
		_badge.position = (size - badge) * badge_anchor + badge_offset
		_badge_label.size = badge
		_badge_label.position = Vector2.ZERO
		_badge_label.add_theme_font_size_override("font_size", int(badge_size * 0.55))
