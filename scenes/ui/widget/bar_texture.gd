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
