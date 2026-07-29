@tool
extends Button

## One entry in the bottom nav bar: a filled tile with an icon, an optional word
## under it, and an optional badge pinned to a corner.
##
## Colour, tile size, icon scale and font are NOT set here — nav_bar.gd owns them
## and pushes the same values into all three entries, so the tiles cannot drift
## apart. This script owns only what differs per entry: which icon, which word,
## whether a badge shows and where.
##
## The tile art is TWO stacked NinePatchRects, the unselected look under the
## selected one, and selecting cross-fades between them via `bg_blend`. That is
## why the background is not a StyleBoxFlat: the reference tiles are vertically
## shaded, and StyleBoxFlat has a single `bg_color` with no gradient of any kind.
## Nine-patching keeps the side edges and the bright top line one pixel thick
## while the middle stretches to the tile's animated width.
##
## Icon / Label / Badge are internal children built in code, so they are never
## written into a .tscn. `_validate_property` strips the generated theme overrides
## for the same reason: a stale baked copy inside a screen would silently override
## whatever you set on the widget itself.

const BADGE_TEXTURE := preload("res://assets/ui/common/ui_notification_badge.png")

## Artwork for this entry. Files live in `assets/ui/nav/`.
@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		if _icon != null:
			_icon.texture = value

## Word shown under the icon. nav_bar decides *whether* it shows (see
## `label_on_selected_only`); this is only what it says.
@export var label_text: String = "":
	set(value):
		label_text = value
		if _label != null:
			_label.text = value
		_layout()

@export_group("Badge")
## Show the little red notification badge on this entry.
@export var badge_visible: bool = false:
	set(value):
		badge_visible = value
		_layout()

## Number or text inside the badge. Leave empty for a plain dot.
@export var badge_text: String = "":
	set(value):
		badge_text = value
		if _badge_label != null:
			_badge_label.text = value

## Badge size in pixels (square).
@export var badge_size: int = 52:
	set(value):
		badge_size = maxi(value, 4)
		_layout()

## Which corner of the tile the badge sits in, as a fraction: (0,0) top-left,
## (1,0) top-right, (0.5,0.5) dead centre.
@export var badge_anchor: Vector2 = Vector2(1, 0):
	set(value):
		badge_anchor = value
		_layout()

## Free pixel nudge on top of `badge_anchor`. Positive y moves it DOWN.
@export var badge_offset: Vector2 = Vector2.ZERO:
	set(value):
		badge_offset = value
		_layout()


## Icon edge length in pixels. nav_bar tweens this when the selection changes,
## which is what makes the icon grow rather than pop.
var icon_px: float = 110.0:
	set(value):
		icon_px = value
		_layout()

## Fades the label in and out during the selection tween.
var label_alpha: float = 1.0:
	set(value):
		label_alpha = value
		if _label != null:
			_label.modulate.a = value

## 0 = unselected tile art, 1 = selected tile art. nav_bar tweens this, which is
## what cross-fades the grey tile into the tan one.
var bg_blend: float = 0.0:
	set(value):
		bg_blend = value
		if _bg_selected != null:
			_bg_selected.modulate.a = value

var _bg_normal: NinePatchRect
var _bg_selected: NinePatchRect
var _icon: TextureRect
var _label: Label
var _badge: TextureRect
var _badge_label: Label

# Pushed in by nav_bar via set_content(); see _layout().
var _icon_offset: Vector2 = Vector2.ZERO
var _label_visible: bool = false
var _label_gap: int = 4
var _label_font_size: int = 34
var _label_offset: Vector2 = Vector2.ZERO


func _init() -> void:
	_build_children()


func _ready() -> void:
	# The tile is resized by nav_bar (and tweened), so re-place the contents.
	if not resized.is_connected(_layout):
		resized.connect(_layout)
	_layout()


# Generated theme overrides must not be serialized into the screens that instance
# this widget — see the header note.
func _validate_property(property: Dictionary) -> void:
	if property.name.begins_with("theme_override_"):
		property.usage &= ~PROPERTY_USAGE_STORAGE


func _build_children() -> void:
	if _icon != null:
		return
	# INTERNAL_MODE_BACK: never saved to a .tscn, never shows in the scene dock.
	# Creation order IS paint order, so the two backgrounds go in first.
	_bg_normal = _make_background()
	_bg_selected = _make_background()
	_bg_selected.modulate.a = bg_blend

	_icon = TextureRect.new()
	_icon.name = "Icon"
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.texture = icon_texture
	add_child(_icon, false, Node.INTERNAL_MODE_BACK)

	_label = Label.new()
	_label.name = "Label"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.text = label_text
	add_child(_label, false, Node.INTERNAL_MODE_BACK)

	_badge = TextureRect.new()
	_badge.name = "Badge"
	_badge.texture = BADGE_TEXTURE
	_badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_badge, false, Node.INTERNAL_MODE_BACK)

	_badge_label = Label.new()
	_badge_label.name = "BadgeLabel"
	_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_badge_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge_label.text = badge_text
	_badge.add_child(_badge_label, false, Node.INTERNAL_MODE_BACK)


## Called by nav_bar. Every entry gets the same numbers, so styling stays in one
## place; only `show_label` differs, and only because the reference shows the word
## on the entry you are on.
func set_content(icon_offset: Vector2, show_label: bool, gap: int,
		font_size: int, font_color: Color, label_offset: Vector2) -> void:
	_icon_offset = icon_offset
	_label_visible = show_label
	_label_gap = gap
	_label_font_size = font_size
	_label_offset = label_offset
	if _label != null:
		_label.add_theme_font_size_override("font_size", font_size)
		_label.add_theme_color_override("font_color", font_color)
	_layout()


func _make_background() -> NinePatchRect:
	var patch := NinePatchRect.new()
	patch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# NEAREST is required, not a preference. The tile texture is a few pixels wide
	# and its centre column gets stretched across the whole tile; under the default
	# linear filter that stretch drags the dark edge colour hundreds of pixels
	# inward, and the tile reads as shaded left-to-right instead of flat.
	patch.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(patch, false, Node.INTERNAL_MODE_BACK)
	return patch


## Called by nav_bar. Both looks are handed over together and the fade between
## them is `bg_blend`; `patch_top` is the bright top line, the one part of the
## artwork that must NOT stretch.
func set_tile_art(normal_texture: Texture2D, selected_texture: Texture2D,
		patch_top: int) -> void:
	# Every state is blanked so Godot's default button plate never shows through
	# and pressing does not flash grey — the nav bar's tween is the whole feedback.
	focus_mode = Control.FOCUS_NONE
	var empty := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(state, empty)

	for pair in [[_bg_normal, normal_texture], [_bg_selected, selected_texture]]:
		var patch: NinePatchRect = pair[0]
		patch.texture = pair[1]
		patch.patch_margin_top = patch_top
	_layout()


func _layout() -> void:
	if _icon == null:
		return

	for patch in [_bg_normal, _bg_selected]:
		patch.position = Vector2.ZERO
		patch.size = size

	var show_label: bool = _label_visible and label_text != ""
	var label_h: float = float(_label_font_size) * 1.25 if show_label else 0.0
	var block_h: float = icon_px + (_label_gap + label_h if show_label else 0.0)
	var top: float = (size.y - block_h) * 0.5

	_icon.size = Vector2(icon_px, icon_px)
	_icon.position = Vector2((size.x - icon_px) * 0.5, top) + _icon_offset

	_label.visible = show_label
	if show_label:
		_label.size = Vector2(size.x, label_h)
		_label.position = Vector2(0.0, top + icon_px + _label_gap) + _label_offset

	_badge.visible = badge_visible
	if badge_visible:
		var badge := Vector2(badge_size, badge_size)
		_badge.size = badge
		_badge.position = (size - badge) * badge_anchor + badge_offset
		_badge_label.size = badge
		_badge_label.position = Vector2.ZERO
		_badge_label.add_theme_font_size_override("font_size", int(badge_size * 0.55))
