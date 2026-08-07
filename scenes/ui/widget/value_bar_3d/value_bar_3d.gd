@tool
extends Node3D

## Preloaded, not a global class name — see the note in bar_texture.gd.
const BarTexture := preload("res://scenes/ui/widget/bar_texture.gd")

## Label3D is a Node3D, not a Control -- it never participates in the project's
## Theme (`ui_theme.tres`), so left unset it falls back to Godot's generic
## built-in font instead of the project's actual typeface. Every 2D Label (like
## "Lv.X") looks different from this number for that reason alone, regardless
## of matching size/outline/shadow.
##
## The font asset's `multichannel_signed_distance_field` import flag went
## true -> false -> true -> false over the course of debugging this number, so
## the final state is worth explaining plainly:
## 1. An early version of the fake-outline below worked by rendering a SCALED-UP
##    duplicate of the text behind the real one. Non-MSDF glyphs didn't reliably
##    hold together on thin diagonal strokes once scaled that way -- the "1"
##    rendered with a broken gap in its stroke, on every outline/embolden value
##    tested. Enabling MSDF fixed that gap.
## 2. That scaled-copy approach was later replaced with same-size, fixed-offset
##    copies instead (see `_value_outlines` below) -- scaling also scaled
##    letter-spacing, which drifted the black copy's letters out from behind
##    the white ones on multi-digit numbers. Fixed offsets don't have that
##    problem, which quietly made MSDF unnecessary again: nothing here scales
##    glyphs anymore, so plain (non-MSDF) glyphs hold together fine.
## 3. MSDF was left on anyway until a white "hourglass" artifact kept appearing
##    over the number in real gameplay, intermittently, only on certain HP
##    values. Isolated per-digit renders (setting `_value.text` to single
##    digits and digit pairs in a minimal test scene) isolated it exactly: the
##    glyph "8" alone, at this weight/size, generates a corrupted MSDF distance
##    field in this Godot build -- its two counters (the enclosed white regions
##    top and bottom of the pinch) render solid white/filled instead of hollow,
##    every single time, deterministically, regardless of neighbouring digits
##    or camera/timing. Raising `msdf_pixel_range`/`msdf_size` did not fix it.
##    Disabling MSDF did, confirmed on "8" alone, "1" alone (see point 1/2 above
##    -- no regression), and the exact multi-digit values that broke in real
##    play ("1289", "1178"). MSDF is off (`multichannel_signed_distance_field
##    =false` on the .import file) for that reason -- this is a real Godot
##    engine/font limitation, not a project bug, and non-MSDF is correct here
##    now that nothing scales glyphs.
## 4. Label3D's native `outline_size` is separately broken when combined with
##    MSDF in this Godot build -- ANY outline_size > 0 renders the entire glyph
##    solid black (fill included). Moot now that MSDF is off, but `outline_size`
##    still isn't used here regardless -- see `_value_outlines` below for how
##    the outline look is actually achieved instead.
const VALUE_FONT := preload("res://assets/fonts/Baloo_2/static/Baloo2-ExtraBold.ttf")

## A SEPARATE white-blob-shaped artifact, easy to confuse with the MSDF "8"
## bug documented above -- both looked like a white shape swallowing part of
## the number, but this one is a depth-sorting problem, unrelated to any
## specific glyph. Root cause: this project's camera is a FIXED PERSPECTIVE
## camera pitched down at the scene
## (`camera_rig.gd`: position `(0, camera_height, camera_distance)`,
## `look_at(Vector3.ZERO, Vector3.UP)`) -- its view direction has both a -Y
## and a -Z component. World-space `Vector2(0, 1)`/`(0, -1)` ("up"/"down") are
## NOT perpendicular to that view direction -- they carry a real depth
## component, so an outline copy offset that way sits measurably closer to or
## farther from the camera than the white text, not just visually adjacent.
## That makes transparent-quad depth sorting between the near-coincident
## layers genuinely ambiguous, and the exact ambiguity depends on camera
## distance -- which changes as the unit walks -- which is why it only broke
## intermittently instead of every time. `SCREEN_RIGHT`/`SCREEN_UP` are
## computed to lie truly in this fixed camera's view-perpendicular plane
## instead of naive world axes, so every outline copy is genuinely coplanar
## with the white text, not just visually close.
const SCREEN_RIGHT := Vector3(1.0, 0.0, 0.0)
const SCREEN_UP := Vector3(0.0, 0.70710678, -0.70710678)
const OUTLINE_DIRS: Array[Vector3] = [
	SCREEN_RIGHT, -SCREEN_RIGHT, SCREEN_UP, -SCREEN_UP,
]

## Generic floating value bar that hovers over a unit and always faces the
## camera -- NOT specific to health. Used for the tower's HP today, and for
## every enemy/boss's HP, but nothing about it assumes "health": it's driven
## purely by a current/max fraction, the same way the 2D HUD bar
## (`value_bar.gd`, used for the XP bar) is driven purely by a 0-100 value.
## An XP, mana, or shield bar in 3D space is the same component with a
## different `style` and whatever drives `set_value()`.
##
## Art comes from `BarTexture.make_capsule()` — the SAME generator the 2D HUD bar
## uses, so the two match automatically and there is only one place to change the
## look. Layers, drawn back to front by `render_priority`: Track (empty bar) →
## Fill (clipped by value) → Rim (outline, baked into Track) → Value (number,
## optional) → its faked outline copies.
##
## Those layers are INTERNAL children built in code, not nodes in the .tscn. That
## is deliberate: a @tool script writing textures onto real child nodes makes
## Godot serialise them as instance overrides into every scene that instances
## this one — that bake is what once grew game_world.tscn to 1.45 MB. Internal
## children are never serialised, so tuning here really does reach every scene
## using this component.
##
## The fill does NOT regenerate its image as the value changes. It uses the
## sprite's `region_rect` to reveal part of the already-drawn capsule and shifts
## `offset` so it stays anchored to the left edge — two floats per update. That
## also means a partly-full bar has a flat right edge, matching the HUD bar and
## the reference art.
##
## No SubViewport: putting a 2D TextureProgressBar in a viewport in 3D is what
## skills/godot3d-vfx-audio/SKILL.md tells us not to do.
##
## Reuse anywhere: instance this scene, optionally assign `style` (see
## `Bar3DStyle`) for a shared look instead of inline-tuning every export, leave
## `follow_game_state` false, and call `set_value(current, max_value)` from
## whatever drives it. If a sibling `HealthComponent` exists it is found and
## wired automatically (see `_ready()`) -- that's the one HP-flavoured
## convenience this otherwise-generic component has, and it simply does
## nothing if there's no `HealthComponent` sibling (an XP/mana/shield bar
## would just call `set_value()` directly instead, the same way the 2D XP bar
## is driven by `GameState.xp_bar_updated`, not a component).

## Shared look, e.g. `resources/ui/enemy_bar_style.tres`. When set, every field
## it defines (see `Bar3DStyle`) is used INSTEAD OF the matching individual
## export below -- those stay available for inline tuning when no shared
## preset is wanted (e.g. the tower's own bar). Assigning a style never mutates
## the individual export fields, so the Inspector doesn't show misleading
## "manually set" values.
@export var style: Bar3DStyle:
	set(value):
		style = value
		_rebuild()

## Bar size in TEXTURE pixels, used when `style` is unset. Combined with
## `pixel_size` this decides how big the bar looks in the world — world size
## is `bar_size * pixel_size`.
##
## This is deliberately about 2x the resolution the bar occupies on screen, i.e.
## it is SUPERSAMPLED. A thin rim drawn at 1:1 is a 2px line stretched across the
## bar's whole width, and mipmap/linear filtering averages it away against the
## transparent pixels outside — which made the outline vanish along the top and
## bottom while surviving on the rounded end caps, where more rim pixels sit
## together. If you raise this, scale `rim_width` and `corner_radius` with it and
## halve `pixel_size` to keep the on-screen size the same.
@export var bar_size: Vector2i = Vector2i(480, 68):
	set(value):
		bar_size = Vector2i(maxi(value.x, 4), maxi(value.y, 4))
		_rebuild()

## World units per texture pixel, used when `style` is unset. Together with
## `bar_size` this is the real "how big is it on screen" knob.
@export var pixel_size: float = 0.003:
	set(value):
		pixel_size = maxf(value, 0.0001)
		_rebuild()

## How far above the unit's origin the bar floats, in world units. Always
## per-instance (depends on each unit's own model height), never part of `style`.
@export var height_offset: float = 2.8:
	set(value):
		height_offset = value
		_rebuild()

## Colour at the top edge of the fill, used when `style` is unset.
@export var color_top: Color = Color(0.45, 0.90, 0.35):
	set(value):
		color_top = value
		_rebuild()

## Colour at the bottom edge of the fill, used when `style` is unset.
@export var color_bottom: Color = Color(0.16, 0.62, 0.18):
	set(value):
		color_bottom = value
		_rebuild()

## Where the fill's gradient finishes, as a fraction of its height, used when
## `style` is unset (same mechanism as the XP bar's `value_bar.gd::color_split`,
## see `BarTexture.make_capsule()`'s `split` doc). `1.0` (the default) is a
## plain gradient over the whole height.
@export_range(0.05, 1.0) var color_split: float = 1.0:
	set(value):
		color_split = clampf(value, 0.05, 1.0)
		_rebuild()

## Colour at the top edge of the empty track behind the fill, used when `style`
## is unset.
@export var track_color_top: Color = Color(0.16, 0.18, 0.24):
	set(value):
		track_color_top = value
		_rebuild()

## Colour at the bottom edge of the empty track, used when `style` is unset.
@export var track_color_bottom: Color = Color(0.09, 0.10, 0.14):
	set(value):
		track_color_bottom = value
		_rebuild()

## Glossy top-edge highlight blended onto the TRACK, used when `style` is
## unset. Alpha 0 (the default) turns it off.
@export var track_highlight_color: Color = Color(1.0, 1.0, 1.0, 0.0):
	set(value):
		track_highlight_color = value
		_rebuild()

## Height of that highlight band, in TEXTURE pixels from the top edge, used
## when `style` is unset. Needs to clear `rim_width` to actually show (the rim
## is a separate layer drawn on top and will otherwise hide a thin highlight
## underneath it). 0 = off.
@export var track_highlight_height: int = 0:
	set(value):
		track_highlight_height = maxi(value, 0)
		_rebuild()

## Colour of the outline framing the bar, used when `style` is unset. Alpha 0
## removes it.
@export var rim_color: Color = Color(0.04, 0.04, 0.06):
	set(value):
		rim_color = value
		_rebuild()

## Outline thickness in TEXTURE pixels, used when `style` is unset, and also
## how far the fill is inset. 0 = no rim.
##
## What matters is this as a FRACTION of `bar_size.y`, because that fraction is
## what survives to the screen -- a rim at 7% of the height can come out under
## one pixel and vanish; ~15% clears a whole pixel. Raise this, not `bar_size`,
## if the outline still reads thin.
@export var rim_width: int = 7:
	set(value):
		rim_width = maxi(value, 0)
		_rebuild()

## Corner radius in TEXTURE pixels, used when `style` is unset. At or above
## half the height = full capsule.
@export var corner_radius: int = 12:
	set(value):
		corner_radius = maxi(value, 0)
		_rebuild()

## Show the current value as a number on the bar, like the reference art.
@export var show_value: bool = true:
	set(value):
		show_value = value
		_rebuild()

## Size of that number. The reference art's number reads noticeably bigger than
## the bar itself, not tucked neatly inside it — 80 against the default 68px-tall
## bar_size gets close to that proportion.
@export var value_font_size: int = 80:
	set(value):
		value_font_size = maxi(value, 1)
		_rebuild()

## How far up the number sits, measured in BAR HEIGHTS.
## `0.0` centres it on the bar, `0.5` centres it on the bar's TOP EDGE so its top
## half hangs above and its bottom half covers the bar's upper part — the
## reference look — and `1.0` clears the bar entirely.
@export var value_raise: float = 0.5:
	set(value):
		value_raise = value
		_rebuild()

## Colour of the faked outline (see `_value_outlines` below). Alpha 0 turns it off.
@export var value_outline_color: Color = Color(0.0, 0.0, 0.0, 1.0):
	set(value):
		value_outline_color = value
		_rebuild()

## Outline thickness, as a fraction of `value_font_size`. This is a fixed
## pixel-style OFFSET applied to identically-sized black copies (see
## `OUTLINE_DIRS`), not a scale multiplier -- scaling the whole string up (the
## first version of this) also scaled the SPACING between letters, so the
## black copy's letters drifted out from behind the white ones on multi-digit
## numbers instead of hugging each glyph, reading as uneven smearing/shadowing
## on the sides rather than a clean outline. Fixed per-direction offsets at the
## SAME font_size don't have that problem.
@export_range(0.0, 0.25) var value_outline_thickness: float = 0.09:
	set(value):
		value_outline_thickness = maxf(value, 0.0)
		_rebuild()

## Draw on top of everything, even when geometry would cover the bar. Leave this
## off unless the bar actually gets clipped by the model.
@export var always_on_top: bool = false:
	set(value):
		always_on_top = value
		_rebuild()

## When true the bar tracks the TOWER's health via GameState on its own, so the
## tower scenes need no script changes. Everything else leaves this false and
## either gets auto-wired to a sibling HealthComponent or calls `set_value()`
## itself.
@export var follow_game_state: bool = true

## Fill fraction shown in the editor only, so the look can be judged at a glance.
## Has no effect while the game is running.
@export_range(0.0, 1.0) var editor_preview_fill: float = 0.7:
	set(value):
		editor_preview_fill = clampf(value, 0.0, 1.0)
		_refresh()

var _track: Sprite3D
var _fill: Sprite3D
var _value_outlines: Array[Label3D] = []
var _value: Label3D

var _current: float = 0.0
var _max: float = 0.0


func _ready() -> void:
	_rebuild()
	if Engine.is_editor_hint():
		return
	if follow_game_state:
		GameState.hp_changed.connect(_on_hp_changed)
		# start_run() and reset() set the HP fields WITHOUT emitting hp_changed,
		# so prime from the current values the way hud.gd does.
		_on_hp_changed(GameState.tower_hp, GameState.tower_max_hp)
	else:
		# Same sibling-discovery pattern as hit_flash_component.gd -- instancing
		# this scene under any unit that already has a HealthComponent (every
		# enemy/boss does) is enough on its own, no per-unit script wiring needed.
		# Harmless no-op for a non-HP bar with no such sibling.
		var health := get_parent().find_child("HealthComponent") as HealthComponent
		if health:
			health.health_changed.connect(set_value)
			# Deferred, not read immediately: enemy.gd's own _ready() (which
			# applies the real max_health from its EnemyDefinition, via direct
			# field assignment with no signal) runs AFTER this child's _ready(),
			# so reading `health` right now would still see HealthComponent's
			# generic 100/100 default, not the real per-enemy value. Deferring
			# to the end of the frame reads it after that's actually happened.
			call_deferred("_prime_from_health", health)


func _on_hp_changed(current: float, max_hp: float) -> void:
	set_value(current, max_hp)


func _prime_from_health(health: HealthComponent) -> void:
	set_value(health.current_health, health.max_health)


## Public API for anything that drives its own current/max value: enemies,
## bosses, or a future XP/mana/shield bar.
func set_value(current: float, max_value: float) -> void:
	if max_value <= 0.0:
		return
	_max = max_value
	_current = clampf(current, 0.0, max_value)
	_refresh()


func _build_layers() -> void:
	if _track != null:
		return
	_track = _add_sprite("Track", 0)
	_fill = _add_sprite("Fill", 1)
	for i in OUTLINE_DIRS.size():
		_value_outlines.append(_add_label("ValueOutline%d" % i, 2))
	_value = _add_label("Value", 3)


## Size of the fill capsule: the bar inset by `rim_width` on every side, so the
## outline baked into the track is always left showing.
func _inner_size(rim_w: int) -> Vector2i:
	return Vector2i(maxi(_eff_bar_size().x - rim_w * 2, 2), maxi(_eff_bar_size().y - rim_w * 2, 2))


## The following `_eff_*()` helpers resolve each style-covered property from
## `style` when it's assigned, falling back to the plain export otherwise --
## kept as small functions rather than duplicating the same ternary at every
## call site.
func _eff_bar_size() -> Vector2i:
	return style.bar_size if style else bar_size

func _eff_pixel_size() -> float:
	return style.pixel_size if style else pixel_size

func _eff_color_top() -> Color:
	return style.color_top if style else color_top

func _eff_color_bottom() -> Color:
	return style.color_bottom if style else color_bottom

func _eff_color_split() -> float:
	return style.color_split if style else color_split

func _eff_track_color_top() -> Color:
	return style.track_color_top if style else track_color_top

func _eff_track_color_bottom() -> Color:
	return style.track_color_bottom if style else track_color_bottom

func _eff_track_highlight_color() -> Color:
	return style.track_highlight_color if style else track_highlight_color

func _eff_track_highlight_height() -> int:
	return style.track_highlight_height if style else track_highlight_height

func _eff_rim_color() -> Color:
	return style.rim_color if style else rim_color

func _eff_rim_width() -> int:
	return style.rim_width if style else rim_width

func _eff_corner_radius() -> int:
	return style.corner_radius if style else corner_radius


func _add_sprite(node_name: String, priority: int) -> Sprite3D:
	var s := Sprite3D.new()
	s.name = node_name
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.render_priority = priority
	add_child(s, false, Node.INTERNAL_MODE_BACK)
	return s


func _add_label(node_name: String, priority: int) -> Label3D:
	var l := Label3D.new()
	l.name = node_name
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.render_priority = priority
	# Label3D's outline is a SEPARATE render pass with its own priority, which
	# defaults to -1 regardless of `render_priority` -- confirmed via a direct
	# check of a fresh Label3D's defaults. Left unset, the outline (-1) sorts
	# behind the Track/Fill sprites (0/1), so wherever the number overlaps the
	# bar (it does, by design -- see `value_raise`) the outline renders hidden
	# underneath it. Matching it to `render_priority` keeps outline and fill
	# sorted together, both above the bar.
	l.outline_render_priority = priority
	l.font = VALUE_FONT
	# ALPHA_CUT_DISCARD was tried here and made things worse: it moves the quad
	# from the transparent render queue (which respects `render_priority`, and
	# is what keeps Value drawing on top of its outline copies) into the OPAQUE
	# queue, which uses hardware depth-test instead. With several near-
	# coincident billboards and no explicit Z separation, that turned into
	# visible depth-fighting between the black and white layers -- confirmed by
	# rendering it. Left at the default (ALPHA_CUT_DISABLED) on purpose.
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(l, false, Node.INTERNAL_MODE_BACK)
	return l


func _rebuild() -> void:
	if not is_inside_tree():
		return
	_build_layers()

	position.y = height_offset

	var rim_w := _eff_rim_width()
	var corner := _eff_corner_radius()

	# The outline is baked into the BOTTOM layer and the fill is inset inside it.
	# It is not a separate quad stacked on top: four billboarded sprites all sat at
	# the same depth, and `render_priority` did not reliably keep the rim above the
	# fill — so the fill covered the outline along the flat top and bottom edges
	# while the rounded caps, where the fill curves inward, still showed it. Insetting
	# makes the outline geometrically unreachable, whatever the sort order does.
	_track.texture = BarTexture.make_capsule(
			_eff_bar_size(), _eff_track_color_top(), _eff_track_color_bottom(), corner,
			_eff_rim_color(), rim_w, false, _eff_track_highlight_color(), _eff_track_highlight_height())
	var inner := _inner_size(rim_w)
	_fill.texture = BarTexture.make_capsule(
			inner, _eff_color_top(), _eff_color_bottom(), maxi(corner - rim_w, 0),
			Color(0, 0, 0, 0), 0, false, Color(0, 0, 0, 0), 0, _eff_color_split())

	for s: Sprite3D in [_track, _fill]:
		s.pixel_size = _eff_pixel_size()
		s.no_depth_test = always_on_top

	_value.visible = show_value
	_value.font_size = value_font_size
	# outline_size is deliberately 0 -- see the class doc's point 2. No native
	# outline is used at all; `_value_outlines` below fakes the look instead.
	_value.modulate = Color.WHITE
	_value.outline_size = 0
	_value.no_depth_test = always_on_top
	# The label is NOT supersampled the way the bar art is — Label3D rasterises its
	# own glyphs at `font_size`, so it stays crisp on its own. It only needs the
	# same world scale as the bar, hence plain `pixel_size`. `value_font_size` is
	# the knob for how big the number reads.
	_value.pixel_size = _eff_pixel_size()
	# Lift it toward the bar's top edge. Expressed in bar heights so the offset
	# tracks bar_size and pixel_size instead of going stale when either changes.
	_value.position.y = _eff_bar_size().y * _eff_pixel_size() * value_raise

	# The fake outline: black copies of the SAME text at the SAME font_size (no
	# scaling, so no letter-spacing drift), each nudged a fixed distance along a
	# true screen-perpendicular direction (see `SCREEN_RIGHT`/`SCREEN_UP` doc)
	# behind the white copy. Together they build up a solid outline silhouette
	# hugging each glyph, with no dependence on the broken native outline_size,
	# and no depth-component drift that could make them sort unpredictably.
	var offset_dist := value_font_size * value_outline_thickness * _eff_pixel_size()
	for i in OUTLINE_DIRS.size():
		var o := _value_outlines[i]
		o.visible = show_value
		o.font_size = value_font_size
		o.outline_size = 0
		o.modulate = value_outline_color
		o.no_depth_test = always_on_top
		o.pixel_size = _eff_pixel_size()
		o.position = _value.position + OUTLINE_DIRS[i] * offset_dist

	_refresh()


func _refresh() -> void:
	if not is_inside_tree() or _fill == null:
		return

	var in_editor := Engine.is_editor_hint()
	var fraction: float = editor_preview_fill
	if not in_editor:
		fraction = 0.0 if _max <= 0.0 else _current / _max

	# All of this works on the INSET size, not bar_size — the fill texture is the
	# smaller capsule that sits inside the outline.
	var inner := _inner_size(_eff_rim_width())
	var revealed: int = int(round(inner.x * fraction))
	_fill.visible = revealed > 0
	_fill.region_enabled = true
	_fill.region_rect = Rect2(0, 0, revealed, inner.y)
	# region_rect shrinks the quad around its centre; shift left by half the loss
	# so the fill stays pinned to the bar's left edge instead of collapsing inward.
	_fill.offset = Vector2(-(inner.x - revealed) * 0.5, 0.0)

	if show_value:
		# In the editor there is no run, so show a stand-in number at the preview
		# fraction just to check the text fits inside the capsule.
		_value.text = str(int(round(2000.0 * fraction))) if in_editor \
				else str(int(round(_current)))
		for o in _value_outlines:
			o.text = _value.text
