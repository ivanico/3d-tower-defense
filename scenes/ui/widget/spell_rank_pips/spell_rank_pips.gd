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

## 0 = unlimited (everything in one row, the original/draft-card behavior).
## Above 0, pips wrap onto additional rows once a row hits this count — the
## HUD spell-stack row's dot count has no fixed max (it just grows with
## picks), so without this a heavily-stacked spell's dots would run wide
## enough to overlap the next spell's icon.
@export var pips_per_row: int = 0:
	set(value):
		pips_per_row = maxi(value, 0)
		_update_min_size()
		queue_redraw()

@export var pip_size: float = 17.0:
	set(value):
		pip_size = maxf(value, 4.0)
		_update_min_size()
		queue_redraw()

@export var gap: float = 15.0:
	set(value):
		gap = maxf(value, 0.0)
		_update_min_size()
		queue_redraw()

@export var filled_color: Color = Color(1.0, 0.82, 0.2)
@export var empty_color: Color = Color(0.02, 0.02, 0.02, 1.0)
@export var outline_color: Color = Color(0.12, 0.09, 0.02)
@export var outline_width: float = 1.5

func _ready() -> void:
	_update_min_size()

func _cols_and_rows() -> Vector2i:
	if pips_per_row <= 0:
		return Vector2i(max_pips, 1)
	var cols := mini(max_pips, pips_per_row)
	var rows := ceili(float(max_pips) / float(pips_per_row))
	return Vector2i(cols, rows)

func _update_min_size() -> void:
	var diag := pip_size * 1.41421356
	var cols_rows := _cols_and_rows()
	custom_minimum_size = Vector2(
		diag * cols_rows.x + gap * (cols_rows.x - 1),
		diag * cols_rows.y + gap * (cols_rows.y - 1)
	)
	if is_inside_tree():
		queue_redraw()

func _draw() -> void:
	var diag := pip_size * 1.41421356
	var per_row := max_pips if pips_per_row <= 0 else pips_per_row
	var cols_rows := _cols_and_rows()
	var block_height := diag * cols_rows.y + gap * (cols_rows.y - 1)
	# Centers the whole (possibly multi-row) block vertically in the
	# control's own rect — with one row this reduces to exactly the old
	# `size.y * 0.5`, so single-row usage (draft cards) is unaffected.
	var top_y := (size.y - block_height) * 0.5
	for i in max_pips:
		var row := i / per_row
		var col := i % per_row
		var x := diag * 0.5 + col * (diag + gap)
		var y := top_y + diag * 0.5 + row * (diag + gap)
		var points := PackedVector2Array([
			Vector2(x, y - pip_size * 0.7071),
			Vector2(x + pip_size * 0.7071, y),
			Vector2(x, y + pip_size * 0.7071),
			Vector2(x - pip_size * 0.7071, y),
		])
		draw_colored_polygon(points, filled_color if i < filled else empty_color)
		draw_polyline(points + PackedVector2Array([points[0]]), outline_color, outline_width)
