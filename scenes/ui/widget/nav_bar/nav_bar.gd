@tool
extends Control

## Bottom navigation shared by every meta screen.
##
## Order is Garage · Worldmap · Codex, with Worldmap deliberately in the MIDDLE:
## the world map is what opens when the game starts, so it is the home position.
##
## Screens set `selected` instead of poking `disabled` on individual buttons. The
## selected entry is drawn larger than the other two, optionally lifted, and is
## disabled so the current screen cannot navigate to itself.
##
## This is a plain Control that positions its three buttons itself rather than an
## HBoxContainer, because a container will not let one child be lifted above the
## others — and `selected_rise` is exactly that. Everything updates live.

enum Nav { GARAGE, WORLDMAP, CODEX }

## Which screen we are on. Sets the matching icon larger and disables its button.
@export var selected: Nav = Nav.WORLDMAP:
	set(value):
		selected = value
		_apply()

## Icon size for the two entries you are NOT on.
@export var normal_size: int = 130:
	set(value):
		normal_size = maxi(value, 8)
		_apply()

## Icon size for the entry you ARE on. Keep it above `normal_size`.
@export var selected_size: int = 180:
	set(value):
		selected_size = maxi(value, 8)
		_apply()

## How many pixels the selected entry is lifted above the other two. 0 = all level.
@export var selected_rise: int = 0:
	set(value):
		selected_rise = value
		_apply()

## Horizontal gap between entries, in pixels.
@export var separation: int = 48:
	set(value):
		separation = maxi(value, 0)
		_apply()

## Free nudge for the whole row, in pixels. Positive y moves it DOWN.
@export var row_offset: Vector2 = Vector2.ZERO:
	set(value):
		row_offset = value
		_apply()


func _ready() -> void:
	# Sizes are relative to the bar's own rect, so re-run whenever that changes.
	if not resized.is_connected(_apply):
		resized.connect(_apply)
	_apply()


## Buttons in `Nav` order, so the enum indexes straight into this.
func _buttons() -> Array:
	return [
		get_node_or_null("GarageButton"),
		get_node_or_null("WorldmapButton"),
		get_node_or_null("CodexButton"),
	]


func _apply() -> void:
	if not is_inside_tree():
		return
	var buttons := _buttons()
	for b in buttons:
		if b == null:
			return

	var sizes: Array[int] = []
	var total: float = 0.0
	for i in buttons.size():
		var s: int = selected_size if i == selected else normal_size
		sizes.append(s)
		total += s
	total += separation * (buttons.size() - 1)

	# Centre the row horizontally, and sit every icon on one baseline so growing
	# the selected one does not shove its neighbours around.
	var x: float = (size.x - total) * 0.5 + row_offset.x
	var baseline: float = (size.y + float(maxi(selected_size, normal_size))) * 0.5
	for i in buttons.size():
		var button: TextureButton = buttons[i]
		var s: int = sizes[i]
		var is_selected: bool = i == selected
		button.custom_minimum_size = Vector2(s, s)
		button.size = Vector2(s, s)
		var lift: float = selected_rise if is_selected else 0.0
		button.position = Vector2(x, baseline - s - lift + row_offset.y)
		button.disabled = is_selected
		x += s + separation
