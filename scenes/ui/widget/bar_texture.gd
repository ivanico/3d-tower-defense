@tool
extends RefCounted

## Consumers `preload()` this rather than reaching for a global `class_name`.
## `class_name` only resolves through .godot/global_script_class_cache.cfg, which
## ONLY the editor rebuilds — so a headless run, a fresh clone, or simply adding
## `class_name` to a script that already existed can fail to parse until someone
## opens the editor. preload has no such dependency.

## Draws the rounded-rect bar art used by BOTH the 2D HUD bar (`value_bar.gd`) and the
## floating 3D bar over the tower (`health_bar_3d.gd`). ONE generator — do not copy this
## loop into either of them.
##
## Why generated instead of a PNG: stretching a bitmap pill to an arbitrary bar size is a
## non-uniform scale, which flattens the round end caps into ovals. Here the capsule is
## rasterised at exactly the size asked for, so the caps are correct at any proportions.
##
## The bar is three of these layers stacked:
##   track  — solid capsule in the dark empty-track colour   (no rim)
##   fill   — solid capsule in the value colour, clipped by the current value
##   rim    — `rim_only` capsule, drawn last so it frames the whole bar


## Rasterises the flat, vertically-shaded tile used by the nav bar.
##
## Generated rather than a StyleBoxFlat because **StyleBoxFlat cannot do gradients
## at all** — it is one solid `bg_color` — and the reference art's whole look is
## the vertical shading. Two pixels wide: the caller stretches it horizontally
## through a NinePatchRect, so the top highlight stays crisp while the rest scales
## to whatever the tile is currently sized to.
##
## The tile carries no side edges. Seams between tiles are drawn separately by
## nav_bar, because edges baked in here would also appear on the OUTER sides of
## the first and last tile, and the bar has to run edge to edge.
##
## The shading is two bands, matching the reference:
##   y < split      — gradient from `top` down to `split_color`
##   y >= split     — flat `bottom`
## `split = 1.0` collapses that to one continuous gradient over the whole height,
## which is what the selected tile uses. `highlight_h` rows at the very top are
## overwritten with `highlight` — the thin bright line that makes it read as shiny.
static func make_tile(height: int, top: Color, split_color: Color, bottom: Color,
		split: float, highlight: Color, highlight_h: int) -> ImageTexture:
	var w := 2
	var h: int = maxi(height, 2)
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)

	# At split = 1.0 this lands on h, so every row takes the gradient branch.
	var split_y: int = clampi(int(round(float(h) * clampf(split, 0.0, 1.0))), 1, h)
	var last: float = maxf(float(split_y - 1), 1.0)

	for y in h:
		var row: Color = bottom
		if y < split_y:
			row = top.lerp(split_color, float(y) / last)
		if y < highlight_h:
			row = highlight
		for x in w:
			img.set_pixel(x, y, row)

	return ImageTexture.create_from_image(img)


## Rasterises a vertical-gradient rounded rectangle.
##
## `radius` is in pixels and is capped at half the shorter side, so anything at or above
## half the height gives a full capsule. `rim_width > 0` blends the outer `rim_width`
## pixels toward `rim_color`. `rim_only = true` keeps that rim and leaves the interior
## transparent — that is the layer that goes on top of the fill.
static func make_capsule(size: Vector2i, top: Color, bottom: Color, radius: int,
		rim_color: Color = Color(0, 0, 0, 0), rim_width: int = 0,
		rim_only: bool = false) -> ImageTexture:
	var w: int = maxi(size.x, 4)
	var h: int = maxi(size.y, 4)
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# A rim-only layer with no rim is simply nothing.
	if rim_only and rim_width <= 0:
		return ImageTexture.create_from_image(img)

	var r: float = minf(float(radius), minf(h, w) * 0.5)
	var half := Vector2(w * 0.5, h * 0.5)
	# Inner rect of the rounded-rect signed distance field.
	var inner := Vector2(maxf(half.x - r, 0.0), maxf(half.y - r, 0.0))
	var rim: float = float(rim_width)

	for y in h:
		var row_colour := top.lerp(bottom, float(y) / maxf(float(h - 1), 1.0))
		for x in w:
			var p := Vector2(x + 0.5, y + 0.5) - half
			var q := Vector2(absf(p.x), absf(p.y)) - inner
			# Negative inside the shape, positive outside, 0 on the edge.
			var dist := Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length() - r
			# 1px anti-aliased outer edge.
			var alpha := clampf(0.5 - dist, 0.0, 1.0)
			if alpha <= 0.0:
				continue

			# Per-pixel copy: blending must not accumulate along the row.
			var px_colour := row_colour
			if rim > 0.0:
				# 1 at the outer edge, fading to 0 one pixel inside `rim_width`.
				var rim_coverage := clampf(dist + rim + 0.5, 0.0, 1.0)
				if rim_only:
					alpha *= rim_coverage * rim_color.a
					if alpha <= 0.0:
						continue
					img.set_pixel(x, y, Color(rim_color.r, rim_color.g, rim_color.b, alpha))
					continue
				px_colour = px_colour.lerp(rim_color, rim_coverage)

			img.set_pixel(x, y, Color(px_colour.r, px_colour.g, px_colour.b, alpha))

	return ImageTexture.create_from_image(img)
