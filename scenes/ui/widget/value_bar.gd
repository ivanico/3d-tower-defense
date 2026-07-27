@tool
extends TextureProgressBar

## Shared by hp_bar and xp_bar — ONE script, both widgets. Do not copy it.
##
## The bar is DRAWN at the exact pixel size you ask for instead of stretching a
## bitmap. That matters because the old approach scaled a 1563x235 pill down to
## 740x56 — a 2:1 non-uniform squash — which flattened the round end caps into
## stretched ovals. Here the capsule is generated at `bar_size`, so the ends are
## always perfectly round no matter what size or proportions you choose.
##
## Everything below is editable in the inspector and updates live.

## On-screen size of the bar, in pixels. The node's rect matches this exactly,
## so its Position is the bar's top-left corner on screen.
@export var bar_size: Vector2i = Vector2i(740, 56):
	set(value):
		bar_size = Vector2i(maxi(value.x, 4), maxi(value.y, 4))
		_rebuild()

## Colour at the top edge of the bar (the lighter highlight).
@export var color_top: Color = Color(0.973, 0.373, 0.353):
	set(value):
		color_top = value
		_rebuild()

## Colour at the bottom edge.
@export var color_bottom: Color = Color(0.780, 0.020, 0.024):
	set(value):
		color_bottom = value
		_rebuild()

## Corner radius in PIXELS. 0 = square corners; anything at or above half the
## bar height gives a full capsule. 8 is the current look — slightly rounded.
@export var corner_radius: int = 8:
	set(value):
		corner_radius = maxi(value, 0)
		_rebuild()


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	var w: int = bar_size.x
	var h: int = bar_size.y
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var radius: float = minf(float(corner_radius), minf(h, w) * 0.5)
	var half := Vector2(w * 0.5, h * 0.5)
	# Inner rect of the rounded-rect signed distance field.
	var inner := Vector2(maxf(half.x - radius, 0.0), maxf(half.y - radius, 0.0))

	for y in h:
		var row_colour := color_top.lerp(color_bottom, float(y) / maxf(float(h - 1), 1.0))
		for x in w:
			var p := Vector2(x + 0.5, y + 0.5) - half
			var q := Vector2(absf(p.x), absf(p.y)) - inner
			var dist := Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length() - radius
			# 1px anti-aliased edge.
			var alpha := clampf(0.5 - dist, 0.0, 1.0)
			if alpha > 0.0:
				img.set_pixel(x, y, Color(row_colour.r, row_colour.g, row_colour.b, alpha))

	texture_progress = ImageTexture.create_from_image(img)
	scale = Vector2.ONE
	custom_minimum_size = Vector2(w, h)
	size = Vector2(w, h)
