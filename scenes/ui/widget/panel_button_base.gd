@tool
extends Button

## Shared look for small drawn (no-art) buttons: a rounded panel with an optional
## outline that darkens while held, plus a glyph drawn on top — the in-run
## `pause_button` (two bars) and the world map's `carousel_arrow` (a chevron).
##
## Drawn, not art: a glyph stays crisp at any size where a 1200px generated icon
## would have to be shrunk (see the UI art sizing rules in components.md).
##
## This owns the panel only. The glyph belongs to the subclass: override
## `_apply_glyph()`, and build glyph nodes as INTERNAL children so they are never
## serialised into a scene that instances the widget.
##
## Everything below is editable in the inspector and updates live.

## Size of the panel, in pixels. Keep it at or above 80x80 — that is the minimum
## touch target for the mobile pass (epic_done/epic_08_polish.md).
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

## Colour of the glyph.
@export var glyph_color: Color = Color(1, 1, 1):
	set(value):
		glyph_color = value
		_apply()


func _ready() -> void:
	_apply()


## The styleboxes are generated in `_apply()`, so they must never be SAVED into a
## scene that instances this widget — the editor otherwise bakes them in as
## instance overrides and the stale copy silently wins over the colours set here.
func _validate_property(property: Dictionary) -> void:
	if property.name.begins_with("theme_override_styles/"):
		property.usage &= ~PROPERTY_USAGE_STORAGE


func _apply() -> void:
	# Property setters fire during scene deserialization, before the tree exists.
	if not is_inside_tree():
		return
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

	_apply_glyph()


## Override: build/position the glyph for the current `button_size`.
func _apply_glyph() -> void:
	pass
