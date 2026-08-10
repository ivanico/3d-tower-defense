@tool
extends Node3D

## Reusable outlined, billboarded 3D text/number label. Factored out of
## `value_bar_3d.gd`'s HP-number implementation so a second consumer (the
## planned `DamageNumber3D`, see `epic_08_polish.md` Task 08-01 and
## `components.md` Section 7) does not have to duplicate this — the outline
## technique below took several false starts to get right and is not worth
## re-deriving per caller. `value_bar_3d.gd` instances this for its own
## number instead of building `Label3D`s directly; see that script's
## `_build_layers()`.
##
## The outline problem is a separate, harder problem than drawing a bar:
## (1) `Label3D` is a `Node3D`, not a `Control`, so it never participates in
##     the project's Theme (`ui_theme.tres`) — a font must be assigned
##     explicitly (`font`, defaulting to `DEFAULT_FONT` below) or it silently
##     falls back to Godot's generic built-in font.
## (2) The font asset's `multichannel_signed_distance_field` import flag went
##     true -> false -> true -> false over the course of debugging this:
##     early on, a SCALED-UP duplicate of the text was used for the outline,
##     and non-MSDF glyphs didn't reliably hold together on thin diagonal
##     strokes once scaled that way (the "1" rendered with a broken gap).
##     Enabling MSDF fixed that gap. Later, the scaled-copy approach was
##     replaced with same-size, fixed-offset copies (see below) — scaling
##     also scaled letter-spacing, which drifted the black copy's letters out
##     from behind the white ones on multi-digit numbers. Fixed offsets don't
##     have that problem, which quietly made MSDF unnecessary again: nothing
##     here scales glyphs, so plain (non-MSDF) glyphs hold together fine.
## (3) MSDF was left on anyway until a white "hourglass" artifact kept
##     appearing over certain digits in real gameplay. Isolated per-digit
##     testing traced it to the glyph "8" alone, at this weight/size,
##     generating a corrupted MSDF distance field in this Godot build — its
##     two counters render solid white/filled instead of hollow, every time,
##     regardless of neighbouring digits. Disabling MSDF fixed it. Non-MSDF
##     is correct here now that nothing scales glyphs.
## (4) Label3D's native `outline_size` is separately broken when combined
##     with MSDF in this Godot build — any outline_size > 0 renders the
##     entire glyph solid black. Moot now that MSDF is off, but `outline_size`
##     still isn't used here regardless — see `_refresh()` below for how the
##     outline look is actually achieved instead: flat-colour copies of the
##     same text at the SAME `font_size` (no scaling), each nudged a fixed
##     distance along `SCREEN_RIGHT`/`SCREEN_UP`.
## (5) Those two directions are computed to lie truly in this project's FIXED,
##     pitched camera's view-perpendicular plane (`camera_rig.gd`: position
##     `(0, camera_height, camera_distance)`, `look_at(Vector3.ZERO, Vector3.UP)`),
##     not naive world axes. World-space `(0,1,0)`/`(0,-1,0)` carry a real
##     depth component under that pitch, so an offset copy sat measurably
##     closer to or farther from the camera than the white text — genuinely
##     different depths, not just visually adjacent — which made transparent
##     -quad depth sorting between the near-coincident layers ambiguous and
##     camera-distance-dependent (surfaced as an intermittent white blob,
##     worse the farther the unit walked). `SCREEN_RIGHT`/`SCREEN_UP` fixed it
##     by keeping every outline copy genuinely coplanar with the white text.
const SCREEN_RIGHT := Vector3(1.0, 0.0, 0.0)
const SCREEN_UP := Vector3(0.0, 0.70710678, -0.70710678)
const OUTLINE_DIRS: Array[Vector3] = [
	SCREEN_RIGHT, -SCREEN_RIGHT, SCREEN_UP, -SCREEN_UP,
]

## Default font, shared with the rest of the game's UI numbers. Overridable
## per-instance via `font` below — e.g. a future `DamageNumber3D` popup using
## a different (monospaced pixel) face, per `epic_08_polish.md` Task 08-01.
const DEFAULT_FONT := preload("res://assets/fonts/Baloo_2/static/Baloo2-ExtraBold.ttf")

@export var font: FontFile = DEFAULT_FONT:
	set(value):
		font = value
		_rebuild()

@export var font_size: int = 80:
	set(value):
		font_size = maxi(value, 1)
		_rebuild()

@export var text_color: Color = Color.WHITE:
	set(value):
		text_color = value
		_rebuild()

## Colour of the faked outline. Alpha 0 turns it off.
@export var outline_color: Color = Color(0.0, 0.0, 0.0, 1.0):
	set(value):
		outline_color = value
		_rebuild()

## Outline thickness, as a fraction of `font_size`. A fixed pixel-style
## OFFSET applied to identically-sized colour copies (see `OUTLINE_DIRS`),
## not a scale multiplier — see the class doc, point (2), for why scaling
## the whole string drifts multi-digit letter-spacing apart instead.
@export_range(0.0, 0.25) var outline_thickness: float = 0.09:
	set(value):
		outline_thickness = maxf(value, 0.0)
		_rebuild()

## World units per texture pixel. Match whatever this label sits near (e.g.
## `ValueBar3D.pixel_size`) so both read at the same visual scale.
@export var pixel_size: float = 0.003:
	set(value):
		pixel_size = maxf(value, 0.0001)
		_rebuild()

## Draw on top of everything, even when geometry would cover the label.
@export var always_on_top: bool = false:
	set(value):
		always_on_top = value
		_rebuild()

## Render priority the outline copies use; the main (coloured) copy always
## uses `base_render_priority + 1` so it sorts above its own outline (see
## `_add_label()`); the shadow (below) always uses `base_render_priority - 1`
## so it sorts behind both. Callers that stack this label against other
## billboards (like `ValueBar3D`'s Track/Fill) should set this to sort
## correctly among them.
@export var base_render_priority: int = 0:
	set(value):
		base_render_priority = value
		_rebuild()

## Drop shadow beneath the text, offset straight down -- matches the look of
## the 2D UI's "Lv.X" label (`LevelLabel` in `game_world.tscn`, which gets
## this via native `Label` shadow properties Label3D doesn't have). Alpha 0
## (the default) turns it off, same convention as `outline_color`.
@export var shadow_color: Color = Color(0.0, 0.0, 0.0, 0.0):
	set(value):
		shadow_color = value
		_rebuild()

## How far the shadow drops, as a fraction of `font_size` -- same fixed-offset
## mechanism as `outline_thickness` (not a scale multiplier, for the same
## letter-spacing-drift reason).
@export_range(0.0, 0.5) var shadow_offset: float = 0.15:
	set(value):
		shadow_offset = maxf(value, 0.0)
		_rebuild()

## The text shown. Also drives the editor preview, since this is `@tool`.
@export var text: String = "123":
	set(value):
		text = value
		_refresh()

## Overall opacity multiplier applied to text, outline, and shadow alpha
## together. `Node3D` has no native `modulate` -- callers that need to fade
## the whole label at once (e.g. `DamageNumber3D`'s despawn tween) animate
## this instead of reaching into internal children.
@export_range(0.0, 1.0) var opacity: float = 1.0:
	set(value):
		opacity = clampf(value, 0.0, 1.0)
		_refresh()

var _label: Label3D
var _outlines: Array[Label3D] = []
var _shadow: Label3D


func _ready() -> void:
	_rebuild()


func _build_layers() -> void:
	# Each layer is guarded independently, not behind one "already built"
	# check -- a script hot-reload in the editor resets these vars to null
	# while the actual child nodes from BEFORE the reload survive underneath,
	# so a single `if _label != null: return` could skip creating a layer
	# added by a later edit (like `_shadow`) forever, leaving it null.
	if _shadow == null:
		_shadow = _add_label("Shadow", base_render_priority - 1)
	if _outlines.is_empty():
		for i in OUTLINE_DIRS.size():
			_outlines.append(_add_label("Outline%d" % i, base_render_priority))
	if _label == null:
		_label = _add_label("Label", base_render_priority + 1)


func _add_label(node_name: String, priority: int) -> Label3D:
	var l := Label3D.new()
	l.name = node_name
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.render_priority = priority
	# Label3D's outline is a SEPARATE render pass with its own priority,
	# defaulting to -1 regardless of `render_priority` — match them so a
	# layer never sorts behind unrelated geometry using that default (same
	# finding documented in `value_bar_3d.gd`'s history before this was
	# extracted here).
	l.outline_render_priority = priority
	# ALPHA_CUT_DISCARD was tried here and made things worse: it moves the quad
	# from the transparent render queue (which respects `render_priority`, and
	# is what keeps the main copy drawing on top of its outline copies) into
	# the OPAQUE queue, which uses hardware depth-test instead. With several
	# near-coincident billboards and no explicit Z separation, that turned
	# into visible depth-fighting between the outline and main layers --
	# confirmed by rendering it. Left at the default (ALPHA_CUT_DISABLED) on
	# purpose.
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(l, false, Node.INTERNAL_MODE_BACK)
	return l


func _rebuild() -> void:
	if not is_inside_tree():
		return
	_build_layers()

	_shadow.font = font
	_shadow.no_depth_test = always_on_top
	_shadow.pixel_size = pixel_size
	_shadow.render_priority = base_render_priority - 1
	_shadow.outline_render_priority = base_render_priority - 1
	for l: Label3D in _outlines:
		l.font = font
		l.no_depth_test = always_on_top
		l.pixel_size = pixel_size
		l.render_priority = base_render_priority
		l.outline_render_priority = base_render_priority
	_label.font = font
	_label.no_depth_test = always_on_top
	_label.pixel_size = pixel_size
	_label.render_priority = base_render_priority + 1
	_label.outline_render_priority = base_render_priority + 1

	_refresh()


func _refresh() -> void:
	if not is_inside_tree() or _label == null:
		return

	_label.text = text
	_label.font_size = font_size
	_label.modulate = Color(text_color.r, text_color.g, text_color.b, text_color.a * opacity)
	# outline_size is deliberately 0 always — see class doc, point (4). No
	# native outline is used; the loop below fakes the look instead.
	_label.outline_size = 0
	_label.position = Vector3.ZERO

	var offset_dist := font_size * outline_thickness * pixel_size
	for i in OUTLINE_DIRS.size():
		var o := _outlines[i]
		o.text = text
		o.font_size = font_size
		o.outline_size = 0
		o.modulate = Color(outline_color.r, outline_color.g, outline_color.b, outline_color.a * opacity)
		o.position = OUTLINE_DIRS[i] * offset_dist

	_shadow.text = text
	_shadow.font_size = font_size
	_shadow.outline_size = 0
	_shadow.modulate = Color(shadow_color.r, shadow_color.g, shadow_color.b, shadow_color.a * opacity)
	_shadow.visible = shadow_color.a > 0.0 and opacity > 0.0
	# Dropped straight down, using the same true-screen-perpendicular "up"
	# direction the outline uses (negated) rather than naive world -Y -- see
	# class doc, point (5), for why that matters under this project's pitched
	# fixed camera.
	_shadow.position = -SCREEN_UP * (font_size * shadow_offset * pixel_size)
