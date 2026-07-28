@tool
extends TextureProgressBar

## Preloaded, not a global class name — see the note in bar_texture.gd.
const BarTexture := preload("res://scenes/ui/widget/bar_texture.gd")

## Shared by hp_bar and xp_bar — ONE script, both widgets. Do not copy it.
##
## The bar is DRAWN at the exact pixel size you ask for instead of stretching a
## bitmap. That matters because the old approach scaled a 1563x235 pill down to
## 740x56 — a 2:1 non-uniform squash — which flattened the round end caps into
## stretched ovals. Here the capsule is generated at `bar_size`, so the ends are
## always perfectly round no matter what size or proportions you choose.
##
## Three stacked layers, all from `BarTexture.make_capsule()`:
##   `texture_under`    the dark empty track you see to the right of the fill
##   `texture_progress` the coloured fill, clipped horizontally by `value`
##   `texture_over`     the rim, drawn last so it frames the whole bar
##
## Because the fill is clipped, a partly-full bar has a FLAT right edge. That is
## correct and matches the reference art — only the track's ends stay round.
##
## Everything below is editable in the inspector and updates live.

## On-screen size of the bar, in pixels. The node's rect matches this exactly,
## so its Position is the bar's top-left corner on screen.
@export var bar_size: Vector2i = Vector2i(740, 52):
	set(value):
		bar_size = Vector2i(maxi(value.x, 4), maxi(value.y, 4))
		_rebuild()

## Colour at the top edge of the fill (the lighter highlight).
@export var color_top: Color = Color(1.0, 0.78, 0.25):
	set(value):
		color_top = value
		_rebuild()

## Colour at the bottom edge of the fill.
@export var color_bottom: Color = Color(0.95, 0.55, 0.08):
	set(value):
		color_bottom = value
		_rebuild()

## Colour at the top edge of the empty track behind the fill.
@export var track_color_top: Color = Color(0.16, 0.18, 0.24):
	set(value):
		track_color_top = value
		_rebuild()

## Colour at the bottom edge of the empty track.
@export var track_color_bottom: Color = Color(0.09, 0.10, 0.14):
	set(value):
		track_color_bottom = value
		_rebuild()

## Colour of the outline framing the bar. Set its alpha to 0 to remove the rim
## without having to zero `rim_width`.
@export var rim_color: Color = Color(0.04, 0.04, 0.06):
	set(value):
		rim_color = value
		_rebuild()

## Thickness of that outline in PIXELS. 0 = no rim.
@export var rim_width: int = 3:
	set(value):
		rim_width = maxi(value, 0)
		_rebuild()

## Corner radius in PIXELS. 0 = square corners; anything at or above half the
## bar height gives a full capsule. 8 is the current look — slightly rounded.
@export var corner_radius: int = 8:
	set(value):
		corner_radius = maxi(value, 0)
		_rebuild()


func _ready() -> void:
	_rebuild()


## The three textures are generated in `_rebuild()`, so they must never be SAVED
## into a scene that instances this widget. Without this, the editor bakes them in
## as instance overrides — that is what grew game_world.tscn to 1.45 MB of
## PackedByteArray — and the stale baked copy then silently wins over the colours
## and sizes set here.
func _validate_property(property: Dictionary) -> void:
	if property.name in ["texture_under", "texture_progress", "texture_over"]:
		property.usage &= ~PROPERTY_USAGE_STORAGE


func _rebuild() -> void:
	texture_under = BarTexture.make_capsule(
			bar_size, track_color_top, track_color_bottom, corner_radius)
	texture_progress = BarTexture.make_capsule(
			bar_size, color_top, color_bottom, corner_radius)
	texture_over = BarTexture.make_capsule(
			bar_size, Color.TRANSPARENT, Color.TRANSPARENT, corner_radius,
			rim_color, rim_width, true)

	scale = Vector2.ONE
	custom_minimum_size = Vector2(bar_size)
	size = Vector2(bar_size)
