@tool
extends Control

## Row of diamond pips showing a spell's permanent Spell Codex rank (out of
## Constants.SPELL_MAX_RANK), for the draft card's bottom row. Drawn in code,
## not from a texture -- no diamond art exists on disk, and this matches the
## project's own convention for this kind of small decorative row (see
## nav_bar.gd / stat_pill.gd / pause_button.gd in ui_tuning.md).

@export var filled: int = 1:
	set(value):
		filled = clampi(value, 0, max_pips)
		queue_redraw()

@export var max_pips: int = 5:
	set(value):
		max_pips = maxi(value, 1)
		_update_min_size()
		queue_redraw()

@export var pip_size: float = 14.0:
	set(value):
		pip_size = maxf(value, 4.0)
		_update_min_size()
		queue_redraw()

@export var gap: float = 6.0:
	set(value):
		gap = maxf(value, 0.0)
		_update_min_size()
		queue_redraw()

@export var filled_color: Color = Color(1.0, 0.82, 0.2)
@export var empty_color: Color = Color(0.3, 0.3, 0.32, 0.6)
@export var outline_color: Color = Color(0.12, 0.09, 0.02)
@export var outline_width: float = 1.5

func _ready() -> void:
	_update_min_size()

func _update_min_size() -> void:
	var diag := pip_size * 1.41421356
	custom_minimum_size = Vector2(diag * max_pips + gap * (max_pips - 1), diag)
	if is_inside_tree():
		queue_redraw()

func _draw() -> void:
	var diag := pip_size * 1.41421356
	var y := size.y * 0.5
	for i in max_pips:
		var x := diag * 0.5 + i * (diag + gap)
		var points := PackedVector2Array([
			Vector2(x, y - pip_size * 0.7071),
			Vector2(x + pip_size * 0.7071, y),
			Vector2(x, y + pip_size * 0.7071),
			Vector2(x - pip_size * 0.7071, y),
		])
		draw_colored_polygon(points, filled_color if i < filled else empty_color)
		draw_polyline(points + PackedVector2Array([points[0]]), outline_color, outline_width)
