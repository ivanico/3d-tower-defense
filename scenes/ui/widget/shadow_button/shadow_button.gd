@tool
class_name ShadowButton
extends Button

## Godot's native Button text has no drop-shadow support (only Label/RichTextLabel
## do), so every plain-text Button in the project used to look thinner than Label
## text set in the same theme, even at the same font and outline size. This mirrors
## `text` onto an internal Label instead, which picks up the theme's Label style
## (outline + shadow) automatically -- no per-node config needed.
##
## `shadow_text = false` opts a button back into native drawing. Use it for buttons
## that combine an icon with text: native Button lays icon and text out together,
## and this widget does not attempt to reproduce that internally.

@export var shadow_text: bool = true:
	set(value):
		shadow_text = value
		_sync()

var _label: Label
var _pending_text: String = ""
var _forwarding: bool = false

# Button overrides get_minimum_size() in C++ without ever calling the
# _get_minimum_size() GDScript virtual, so that hook is a no-op here -- the
# label's natural size has to be folded into custom_minimum_size instead.
# Captured once _ready, so re-syncing never overwrites a size the scene
# author set on purpose, only grows past it if the text needs more room.
var _base_custom_min: Vector2 = Vector2.ZERO
var _is_ready: bool = false


func _init() -> void:
	_build_label()


func _build_label() -> void:
	if _label != null:
		return
	_label = Label.new()
	_label.name = "ShadowLabel"
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_label, false, Node.INTERNAL_MODE_BACK)


func _ready() -> void:
	_base_custom_min = custom_minimum_size
	_is_ready = true
	_sync_theme()
	_sync()


func _set(property: StringName, value) -> bool:
	if property == &"text" and not _forwarding:
		_pending_text = value
		_sync()
		return true
	return false


func _get(property: StringName):
	if property == &"text":
		return _pending_text
	return null


func _sync() -> void:
	_build_label()
	_forwarding = true
	text = "" if shadow_text else _pending_text
	_forwarding = false
	_label.visible = shadow_text
	_label.text = _pending_text
	_update_min_size()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_sync_theme()


func _sync_theme() -> void:
	if _label == null:
		return
	_label.add_theme_font_size_override("font_size", get_theme_font_size("font_size"))
	_label.add_theme_color_override("font_color", get_theme_color("font_color"))
	_update_min_size()


func _update_min_size() -> void:
	if not _is_ready or not shadow_text or _label == null:
		return
	var pad := Vector2.ZERO
	var style: StyleBox = get_theme_stylebox("normal")
	if style != null:
		pad = style.get_minimum_size()
	custom_minimum_size = _base_custom_min.max(_label.get_minimum_size() + pad)
