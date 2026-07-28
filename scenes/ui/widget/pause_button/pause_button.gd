@tool
extends Button

## Top-left in-run pause button.
##
## Drawn, not art: there is no pause-glyph PNG in assets/ui/, and a two-bar glyph
## stays crisp at any size where a 1200px generated icon would have to be shrunk
## (see the UI art sizing rules in components.md).
##
## This widget is only the LOOK and the `pressed` signal. It deliberately does not
## touch `get_tree().paused` — the draft phase, victory and defeat all drive tree
## pause too, so the toggle lives in `hud.gd` where the game phase is known and a
## second uncoordinated pause source can't fight them.
##
## Everything below is editable in the inspector and updates live.

## Size of the square panel, in pixels. Keep it at or above 80x80 — that is the
## minimum touch target for the mobile pass (epic_08_polish.md).
@export var button_size: Vector2i = Vector2i(96, 96):
	set(value):
		button_size = Vector2i(maxi(value.x, 8), maxi(value.y, 8))
		_apply()

## Panel fill colour.
@export var panel_color: Color = Color(0.13, 0.15, 0.20, 0.85):
	set(value):
		panel_color = value
		_apply()

## Panel corner radius in PIXELS. At half the button size you get a circle.
@export var corner_radius: int = 24:
	set(value):
		corner_radius = maxi(value, 0)
		_apply()

## Outline colour. Only drawn when `border_width` is above 0.
@export var border_color: Color = Color(0.85, 0.88, 0.95, 0.55):
	set(value):
		border_color = value
		_apply()

## Outline thickness in PIXELS. 0 = no outline.
@export var border_width: int = 2:
	set(value):
		border_width = maxi(value, 0)
		_apply()

## How much darker the panel goes while held down. 0 = no feedback, 1 = black.
@export_range(0.0, 1.0) var pressed_dim: float = 0.25:
	set(value):
		pressed_dim = clampf(value, 0.0, 1.0)
		_apply()

## Colour of the two pause bars.
@export var glyph_color: Color = Color(1, 1, 1):
	set(value):
		glyph_color = value
		_apply()

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


func _ready() -> void:
	_apply()


## The styleboxes are generated in `_apply()`, so they must never be SAVED into a
## scene that instances this widget — the editor otherwise bakes them in as
## instance overrides and the stale copy silently wins over the colours set here.
func _validate_property(property: Dictionary) -> void:
	if property.name.begins_with("theme_override_styles/"):
		property.usage &= ~PROPERTY_USAGE_STORAGE


## The two glyph bars are INTERNAL children built here rather than nodes in the
## .tscn, for the same reason: internal children are never serialised, so nothing
## about them can be baked into game_world.tscn.
func _build_glyph() -> void:
	if _left != null:
		return
	_left = Panel.new()
	_right = Panel.new()
	for p: Panel in [_left, _right]:
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(p, false, Node.INTERNAL_MODE_BACK)


func _apply() -> void:
	# Property setters fire during scene deserialization, before the tree exists.
	if not is_inside_tree():
		return
	_build_glyph()
	var left: Panel = _left
	var right: Panel = _right

	custom_minimum_size = Vector2(button_size)
	size = Vector2(button_size)

	var panel := StyleBoxFlat.new()
	panel.bg_color = panel_color
	panel.set_corner_radius_all(corner_radius)
	if border_width > 0:
		panel.set_border_width_all(border_width)
		panel.border_color = border_color
	var held := panel.duplicate() as StyleBoxFlat
	held.bg_color = panel_color.darkened(pressed_dim)

	add_theme_stylebox_override("normal", panel)
	add_theme_stylebox_override("hover", panel)
	add_theme_stylebox_override("focus", panel)
	add_theme_stylebox_override("disabled", panel)
	add_theme_stylebox_override("pressed", held)

	# One StyleBox shared by both bars — they are always identical.
	var glyph := StyleBoxFlat.new()
	glyph.bg_color = glyph_color
	glyph.set_corner_radius_all(glyph_corner_radius)
	left.add_theme_stylebox_override("panel", glyph)
	right.add_theme_stylebox_override("panel", glyph)

	var centre := Vector2(button_size) * 0.5
	var bar := Vector2(glyph_bar_size)
	left.size = bar
	right.size = bar
	left.position = Vector2(centre.x - glyph_gap * 0.5 - bar.x, centre.y - bar.y * 0.5)
	right.position = Vector2(centre.x + glyph_gap * 0.5, centre.y - bar.y * 0.5)
