@tool
extends "res://scenes/ui/widget/panel_button_base.gd"

## Round arrow button: the shared drawn panel (panel_button_base.gd) with a
## chevron glyph pointing left or right. Built for the 09-09 chapter carousel;
## since the Archero-style change (2026-10-06) it is the chapter screen's Back
## button (chapter_select.tscn, pointing left).
## Placeholder for the optional final art `world_map/ui_carousel_arrow.png`
## (Epic 09 rule 1).
##
## Only the LOOK and the `pressed` signal. What a press does belongs to the
## screen that uses it.
##
## Everything below is editable in the inspector and updates live.

enum Direction { LEFT, RIGHT }

## Which way the chevron points.
@export var direction: Direction = Direction.RIGHT:
	set(value):
		direction = value
		_apply()

## Width (depth of the point) and height of the chevron, in pixels.
@export var glyph_size: Vector2i = Vector2i(26, 48):
	set(value):
		glyph_size = Vector2i(maxi(value.x, 1), maxi(value.y, 1))
		_apply()

## Stroke thickness of the chevron, in pixels.
@export var glyph_thickness: float = 9.0:
	set(value):
		glyph_thickness = maxf(value, 1.0)
		_apply()


var _glyph: Control


## The chevron is drawn on an INTERNAL child (never serialised into the world
## map scene), so it paints over the panel stylebox like the pause bars do.
func _build_glyph() -> void:
	if _glyph != null:
		return
	_glyph = Control.new()
	_glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glyph.draw.connect(_draw_chevron)
	add_child(_glyph, false, Node.INTERNAL_MODE_BACK)


func _apply_glyph() -> void:
	_build_glyph()
	_glyph.position = Vector2.ZERO
	_glyph.size = Vector2(button_size)
	_glyph.queue_redraw()


func _draw_chevron() -> void:
	var centre := Vector2(button_size) * 0.5
	var half := Vector2(glyph_size) * 0.5
	# The point sits on the side the arrow points to.
	var dir_x := 1.0 if direction == Direction.RIGHT else -1.0
	var points := PackedVector2Array([
		centre + Vector2(-half.x * dir_x, -half.y),
		centre + Vector2(half.x * dir_x, 0.0),
		centre + Vector2(-half.x * dir_x, half.y),
	])
	_glyph.draw_polyline(points, glyph_color, glyph_thickness, true)
	# Round the three stroke ends so the joint and tips don't look clipped.
	for p in points:
		_glyph.draw_circle(p, glyph_thickness * 0.5, glyph_color)
