@tool
extends "res://scenes/ui/widget/badge_button_base.gd"

## A small icon button on the home screen (10-02): Chests, Daily, Settings.
## Archero-style: the icon with a short word under it, no plate behind, and the
## shared red badge (`badge_button_base.gd`) when something can be claimed.
##
## Only the LOOK and `pressed`. What a press opens belongs to the screen
## (world_map_content.gd), which sends it through the 10-01 popup host.
##
## No icon art yet? Leave `icon_texture` empty and pick a `placeholder_glyph`:
## a simple calendar or gear drawn in code, standing in for the final
## `world_map/icon_home_daily.png` / `icon_home_settings.png` (Epic 09 rule 1).
## Setting `icon_texture` hides the glyph, so the swap is one property.
##
## Icon, glyph, label and badge are INTERNAL children, never written into a .tscn.
## Everything below is editable in the inspector and updates live.

enum Glyph { NONE, CALENDAR, GEAR }

## The button's art. Overrides `placeholder_glyph` when set.
@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		_layout()

## Drawn stand-in used while `icon_texture` is empty.
@export var placeholder_glyph: Glyph = Glyph.NONE:
	set(value):
		placeholder_glyph = value
		_layout()

## Word under the icon. Empty = icon only, centred.
@export var label_text: String = "":
	set(value):
		label_text = value
		_layout()

## Whole button (touch area). Keep it at or above 80x80.
@export var button_size: Vector2i = Vector2i(130, 150):
	set(value):
		button_size = Vector2i(maxi(value.x, 8), maxi(value.y, 8))
		_layout()

## Icon (or glyph) edge length in pixels.
@export var icon_size: int = 110:
	set(value):
		icon_size = maxi(value, 8)
		_layout()

## Fine-tune how big the ART reads without moving anything — for art that fills
## less of its canvas than the others (see ui_tuning.md "Icons are not the size
## you think").
@export var icon_scale: float = 1.0:
	set(value):
		icon_scale = maxf(value, 0.05)
		_layout()

@export var label_font_size: int = 26:
	set(value):
		label_font_size = maxi(value, 4)
		_layout()

## How much darker the whole button goes while held. 0 = no feedback.
@export_range(0.0, 1.0) var pressed_dim: float = 0.25

## Main colour of the drawn placeholder glyphs.
@export var glyph_color: Color = Color(0.92, 0.92, 0.95):
	set(value):
		glyph_color = value
		_layout()

var _icon: TextureRect
var _glyph: Control
var _label: Label


func _init() -> void:
	_build_children()


func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	var empty := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(state, empty)
	if not Engine.is_editor_hint():
		button_down.connect(_set_held.bind(true))
		button_up.connect(_set_held.bind(false))
	_layout()


# The generated empty styleboxes must not be saved into screens that instance this.
func _validate_property(property: Dictionary) -> void:
	if property.name.begins_with("theme_override_"):
		property.usage &= ~PROPERTY_USAGE_STORAGE


func _build_children() -> void:
	if _icon != null:
		return
	# Creation order is paint order: art, then label, then the badge on top.
	_icon = TextureRect.new()
	_icon.name = "Icon"
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_icon, false, Node.INTERNAL_MODE_BACK)

	_glyph = Control.new()
	_glyph.name = "Glyph"
	_glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glyph.draw.connect(_draw_glyph)
	add_child(_glyph, false, Node.INTERNAL_MODE_BACK)

	_label = Label.new()
	_label.name = "Label"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label, false, Node.INTERNAL_MODE_BACK)

	_build_badge()


func _set_held(held: bool) -> void:
	var shade := 1.0 - pressed_dim if held else 1.0
	modulate = Color(shade, shade, shade, 1.0)


func _layout() -> void:
	if _icon == null:
		return
	custom_minimum_size = Vector2(button_size)
	size = Vector2(button_size)

	var show_label := label_text != ""
	var label_h := float(label_font_size) * 1.3 if show_label else 0.0
	var icon_px := float(icon_size)
	var top := (size.y - icon_px - label_h) * 0.5
	var icon_rect := Rect2(Vector2((size.x - icon_px) * 0.5, top), Vector2(icon_px, icon_px))
	# icon_scale grows/shrinks the art about the same centre.
	var drawn := icon_rect.grow((icon_px * icon_scale - icon_px) * 0.5)

	_icon.texture = icon_texture
	_icon.visible = icon_texture != null
	_icon.position = drawn.position
	_icon.size = drawn.size

	_glyph.visible = icon_texture == null and placeholder_glyph != Glyph.NONE
	_glyph.position = drawn.position
	_glyph.size = drawn.size
	_glyph.queue_redraw()

	_label.visible = show_label
	_label.text = label_text
	_label.add_theme_font_size_override("font_size", label_font_size)
	_label.position = Vector2(0.0, icon_rect.end.y)
	_label.size = Vector2(size.x, label_h)

	_layout_badge()


func _draw_glyph() -> void:
	var s := _glyph.size.x
	var outline := Color(0.08, 0.06, 0.12, 0.9)
	match placeholder_glyph:
		Glyph.CALENDAR:
			# Page with a red header strip, two binder rings and a grid of days.
			var body := Rect2(s * 0.12, s * 0.18, s * 0.76, s * 0.7)
			_glyph.draw_rect(body.grow(s * 0.03), outline)
			_glyph.draw_rect(body, glyph_color)
			_glyph.draw_rect(Rect2(body.position, Vector2(body.size.x, s * 0.2)),
					Color(0.85, 0.2, 0.2))
			for x in [0.32, 0.68]:
				_glyph.draw_rect(Rect2(s * x - s * 0.04, s * 0.1, s * 0.08, s * 0.16), outline)
			for row in 2:
				for col in 3:
					var cell := Vector2(s * (0.24 + col * 0.2), s * (0.48 + row * 0.18))
					_glyph.draw_rect(Rect2(cell, Vector2(s * 0.12, s * 0.1)),
							Color(0.45, 0.45, 0.5))
		Glyph.GEAR:
			# Eight teeth around a disc with a hole.
			var c := Vector2(s, s) * 0.5
			var tooth := Vector2(s * 0.16, s * 0.2)
			for pass_color in [outline, glyph_color]:
				var pad := s * 0.03 if pass_color == outline else 0.0
				for k in 8:
					_glyph.draw_set_transform(c, TAU * k / 8.0)
					_glyph.draw_rect(Rect2(-tooth.x * 0.5 - pad, -s * 0.46 - pad,
							tooth.x + pad * 2.0, tooth.y + pad * 2.0), pass_color)
				_glyph.draw_set_transform(Vector2.ZERO)
				_glyph.draw_circle(c, s * 0.33 + pad, pass_color)
			_glyph.draw_circle(c, s * 0.13, outline)
