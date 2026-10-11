@tool
extends Control

## One Archero-style popup (10-01): a full-screen dim, a centred panel holding a
## content scene, and the red X on the panel's top-right corner. Opens with a
## pop-in (scale up + fade), closes with the reverse.
##
## Only the LOOK and the close request. Who opens it, the stack of open popups,
## and Escape / Android back all belong to `overlay_host.gd`, which instances
## one of these per open popup.
##
## Per-popup options are read off the content scene's root, if it declares them:
## - `overlay_show_close: bool` (default true) — false hides the X
## - `overlay_tap_outside_closes: bool` (default true) — false keeps a tap on
##   the dim from closing it
## - `custom_minimum_size` — the panel's size; zero falls back to `panel_size`
## - a `close_requested` signal — e.g. a Claim button closing its own popup
##
## Editor preview: `Panel/Content/PreviewContent` is a sample child so the scene
## shows something; `set_content()` replaces it at runtime.
##
## Everything below is editable in the inspector and updates live.

signal close_requested
## Emitted once the close animation has finished, just before this frees itself.
signal closed

## The dark layer over the whole screen, NavBar included.
@export var dim_color: Color = Color(0, 0, 0, 0.65):
	set(value):
		dim_color = value
		_apply()

## Panel size when the content scene doesn't set its own `custom_minimum_size`.
@export var panel_size: Vector2 = Vector2(900, 1200):
	set(value):
		panel_size = Vector2(maxf(value.x, 1.0), maxf(value.y, 1.0))
		_apply()

## The panel's own background. Alpha 0 hides it, for content that draws its own.
@export var panel_color: Color = Color(0.1, 0.05, 0.18, 0.95):
	set(value):
		panel_color = value
		_apply()

## Panel corner radius in pixels.
@export var corner_radius: int = 28:
	set(value):
		corner_radius = maxi(value, 0)
		_apply()

## Panel outline. Only drawn when `border_width` is above 0.
@export var border_color: Color = Color(0.85, 0.7, 0.4, 1):
	set(value):
		border_color = value
		_apply()

@export var border_width: int = 4:
	set(value):
		border_width = maxi(value, 0)
		_apply()

## Edge length of the X. Keep it at or above 80 for touch.
@export var close_button_size: float = 120.0:
	set(value):
		close_button_size = maxf(value, 8.0)
		_apply()

## Where the X's CENTRE sits, relative to the panel's top-right corner.
## +x right, +y down. (-20, 20) tucks it slightly inside the corner.
@export var close_button_offset: Vector2 = Vector2(-20, 20):
	set(value):
		close_button_offset = value
		_apply()

## How much darker the X goes while held. 0 = no feedback, 1 = black.
@export_range(0.0, 1.0) var close_pressed_dim: float = 0.25

## Seconds the pop-in takes. Closing takes `close_time`.
@export var open_time: float = 0.18
@export var close_time: float = 0.12

## Panel scale the pop-in starts from (and the close shrinks back to).
@export_range(0.1, 1.0) var open_scale: float = 0.85

## Tap on the dim closes. Overridden per popup by `overlay_tap_outside_closes`.
var tap_outside_closes: bool = true

@onready var dim: ColorRect = $Dim
@onready var panel: Control = $Panel
@onready var content_slot: Control = $Panel/Content
@onready var close_button: TextureButton = $Panel/CloseButton

var _content: Control
var _closing: bool = false
var _tween: Tween


func _ready() -> void:
	panel.draw.connect(_draw_panel)
	if not Engine.is_editor_hint():
		dim.gui_input.connect(_on_dim_input)
		close_button.pressed.connect(_request_close)
		close_button.button_down.connect(_set_close_held.bind(true))
		close_button.button_up.connect(_set_close_held.bind(false))
	_apply()


## Puts `content` in the panel (removing the preview child) and applies the
## per-popup options it declares.
func set_content(content: Control) -> void:
	for child in content_slot.get_children():
		content_slot.remove_child(child)
		child.queue_free()
	_content = content
	content_slot.add_child(content)
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if content.custom_minimum_size != Vector2.ZERO:
		panel_size = content.custom_minimum_size
	var show_close = content.get("overlay_show_close")
	close_button.visible = show_close != false
	var tap_closes = content.get("overlay_tap_outside_closes")
	tap_outside_closes = tap_closes != false
	if content.has_signal("close_requested"):
		content.close_requested.connect(_request_close)
	_apply()


func get_content() -> Control:
	return _content


func is_closing() -> bool:
	return _closing


func play_open() -> void:
	_kill_tween()
	panel.pivot_offset = panel_size * 0.5
	dim.modulate.a = 0.0
	panel.modulate.a = 0.0
	panel.scale = Vector2.ONE * open_scale
	_tween = create_tween().set_parallel()
	_tween.tween_property(dim, "modulate:a", 1.0, open_time)
	_tween.tween_property(panel, "modulate:a", 1.0, open_time)
	_tween.tween_property(panel, "scale", Vector2.ONE, open_time) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Plays the close animation, then emits `closed` and frees itself. Calling it
## again while closing does nothing.
func play_close() -> void:
	if _closing:
		return
	_closing = true
	_kill_tween()
	panel.pivot_offset = panel_size * 0.5
	_tween = create_tween().set_parallel()
	_tween.tween_property(dim, "modulate:a", 0.0, close_time)
	_tween.tween_property(panel, "modulate:a", 0.0, close_time)
	_tween.tween_property(panel, "scale", Vector2.ONE * open_scale, close_time) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.chain().tween_callback(_finish_close)


func _finish_close() -> void:
	closed.emit()
	queue_free()


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()


func _request_close() -> void:
	if not _closing:
		close_requested.emit()


## A tap (press + release) on the dim, i.e. outside the panel.
func _on_dim_input(event: InputEvent) -> void:
	if tap_outside_closes and event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_request_close()


func _set_close_held(held: bool) -> void:
	var shade := 1.0 - close_pressed_dim if held else 1.0
	close_button.self_modulate = Color(shade, shade, shade, 1.0)


func _apply() -> void:
	# Property setters fire during scene deserialization, before the tree exists.
	if not is_inside_tree() or panel == null:
		return
	dim.color = dim_color
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -panel_size.x * 0.5
	panel.offset_top = -panel_size.y * 0.5
	panel.offset_right = panel_size.x * 0.5
	panel.offset_bottom = panel_size.y * 0.5
	var half := Vector2.ONE * close_button_size * 0.5
	var centre := Vector2(panel_size.x, 0.0) + close_button_offset
	close_button.position = centre - half
	close_button.size = half * 2.0
	panel.queue_redraw()


## Drawn rather than a stylebox override, so nothing generated is ever saved
## into this scene.
func _draw_panel() -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = panel_color
	box.set_corner_radius_all(corner_radius)
	if border_width > 0:
		box.set_border_width_all(border_width)
		box.border_color = border_color
	panel.draw_style_box(box, Rect2(Vector2.ZERO, panel.size))
