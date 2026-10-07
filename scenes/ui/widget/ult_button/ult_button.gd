@tool
extends "res://scenes/ui/widget/panel_button_base.gd"

## In-run ult button (09-13, tap mode). A round drawn panel (panel_button_base)
## with a charge ring that fills clockwise in the ult's school colour, and a
## filled, brighter circle once it's ready. Pressing it while ready asks the
## tower's ult to fire (EventBus.ult_fire_requested); the ult decides.
##
## Placeholder for the final art `hud/icon_ult_<tower_id>.png` (Epic 09 rule 1):
## the school-coloured circle stands in for the icon.
##
## Driven only by EventBus.ult_charge_changed, so it needs no reference to the
## tower. Hidden until an ult reports in, and always in AUTO mode.
##
## Everything below is editable in the inspector and updates live.

## EDITOR ONLY: how full the ring looks in the editor. 1 = the ready look.
@export_range(0.0, 1.0) var preview_charge: float = 0.6:
	set(value):
		preview_charge = value
		_apply()

## EDITOR ONLY: which school colour the preview uses.
@export_enum("Fire", "Frost", "Void", "Poison", "Nature") var preview_school: int = 4:
	set(value):
		preview_school = value
		_apply()

## Thickness of the charge ring, in pixels.
@export var ring_width: float = 12.0:
	set(value):
		ring_width = maxf(value, 1.0)
		_apply()

## Colour of the empty part of the ring.
@export var ring_track_color: Color = Color(0, 0, 0, 0.45):
	set(value):
		ring_track_color = value
		_apply()

var _ratio: float = 0.0
var _ready_to_fire: bool = false
var _school: int = Constants.DamageType.NATURE
var _glyph: Control


func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	visible = false
	EventBus.ult_charge_changed.connect(_on_charge_changed)
	pressed.connect(_on_pressed)


func _on_charge_changed(ratio: float, is_ready: bool, school: int) -> void:
	_ratio = ratio
	_ready_to_fire = is_ready
	_school = school
	visible = Constants.ULT_TRIGGER_MODE == Constants.UltTrigger.TAP
	if _glyph:
		_glyph.queue_redraw()


func _on_pressed() -> void:
	if _ready_to_fire:
		EventBus.ult_fire_requested.emit()


func _build_glyph() -> void:
	if _glyph != null:
		return
	_glyph = Control.new()
	_glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glyph.draw.connect(_draw_charge)
	add_child(_glyph, false, Node.INTERNAL_MODE_BACK)


func _apply_glyph() -> void:
	_build_glyph()
	_glyph.position = Vector2.ZERO
	_glyph.size = Vector2(button_size)
	_glyph.queue_redraw()


func _draw_charge() -> void:
	var ratio := preview_charge if Engine.is_editor_hint() else _ratio
	var school := preview_school if Engine.is_editor_hint() else _school
	var is_full := ratio >= 1.0
	var color := CombatUtils.get_damage_color(school)
	var centre := Vector2(button_size) * 0.5
	var radius := minf(button_size.x, button_size.y) * 0.5 - ring_width * 0.5 - float(border_width)
	# The "icon": a school-coloured disc, dim while charging, bright when ready.
	var disc := color if is_full else color.darkened(0.55)
	_glyph.draw_circle(centre, radius - ring_width * 0.5 - 4.0, disc)
	# Charge ring: track, then the filled arc from 12 o'clock, clockwise.
	_glyph.draw_arc(centre, radius, 0.0, TAU, 64, ring_track_color, ring_width, true)
	if ratio > 0.0:
		var start := -PI * 0.5
		_glyph.draw_arc(centre, radius, start, start + TAU * ratio, 64,
				color.lightened(0.25) if is_full else color, ring_width, true)
