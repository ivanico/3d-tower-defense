@tool
extends "res://scenes/ui/widget/panel_button_base.gd"

## Top-left in-run pause button: the shared drawn panel (panel_button_base.gd)
## with a two-bar pause glyph. There is no pause-glyph PNG in assets/ui/.
##
## This widget is only the LOOK and the `pressed` signal. It deliberately does not
## touch `get_tree().paused` — the draft phase, victory and defeat all drive tree
## pause too, so the toggle lives in `hud.gd` where the game phase is known and a
## second uncoordinated pause source can't fight them.
##
## Everything below is editable in the inspector and updates live.

## Size of ONE of the two pause bars, in pixels.
@export var glyph_bar_size: Vector2i = Vector2i(14, 42):
	set(value):
		glyph_bar_size = Vector2i(maxi(value.x, 1), maxi(value.y, 1))
		_apply()

## Gap between the two bars, in pixels.
@export var glyph_gap: int = 14:
	set(value):
		glyph_gap = maxi(value, 0)
		_apply()

## Corner radius of the pause bars, in pixels.
@export var glyph_corner_radius: int = 4:
	set(value):
		glyph_corner_radius = maxi(value, 0)
		_apply()


var _left: Panel
var _right: Panel


## The two glyph bars are INTERNAL children built here rather than nodes in the
## .tscn: internal children are never serialised, so nothing about them can be
## baked into game_world.tscn.
func _build_glyph() -> void:
	if _left != null:
		return
	_left = Panel.new()
	_right = Panel.new()
	for p: Panel in [_left, _right]:
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(p, false, Node.INTERNAL_MODE_BACK)


func _apply_glyph() -> void:
	_build_glyph()
	# One StyleBox shared by both bars — they are always identical.
	var glyph := StyleBoxFlat.new()
	glyph.bg_color = glyph_color
	glyph.set_corner_radius_all(glyph_corner_radius)
	_left.add_theme_stylebox_override("panel", glyph)
	_right.add_theme_stylebox_override("panel", glyph)

	var centre := Vector2(button_size) * 0.5
	var bar := Vector2(glyph_bar_size)
	_left.size = bar
	_right.size = bar
	_left.position = Vector2(centre.x - glyph_gap * 0.5 - bar.x, centre.y - bar.y * 0.5)
	_right.position = Vector2(centre.x + glyph_gap * 0.5, centre.y - bar.y * 0.5)
