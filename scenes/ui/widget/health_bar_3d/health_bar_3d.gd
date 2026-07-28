@tool
extends Node3D

## Preloaded, not a global class name — see the note in bar_texture.gd.
const BarTexture := preload("res://scenes/ui/widget/bar_texture.gd")

## Floating health bar that hovers over a unit and always faces the camera.
##
## Art comes from `BarTexture.make_capsule()` — the SAME generator the 2D HUD bar
## uses, so the two match automatically and there is only one place to change the
## look. Four billboarded layers, drawn back to front by `render_priority`:
## Track (empty bar) → Fill (clipped by health) → Rim (outline) → Value (number).
##
## Those four are INTERNAL children built in code, not nodes in the .tscn. That is
## deliberate: a @tool script writing textures onto real child nodes makes Godot
## serialise them as instance overrides into every scene that instances this one —
## five tower scenes' worth of baked ImageTexture blobs that would then silently
## win over the values set here. Internal children are never serialised, so tuning
## in this scene really does reach all five towers. (That bake is what previously
## grew game_world.tscn to 1.45 MB.)
##
## The fill does NOT regenerate its image as health changes. It uses the sprite's
## `region_rect` to reveal part of the already-drawn capsule and shifts `offset` so
## it stays anchored to the left edge — two floats per update. That also means a
## partly-full bar has a flat right edge, matching the HUD bar and the reference art.
##
## No SubViewport: putting a 2D TextureProgressBar in a viewport in 3D is what
## skills/godot3d-vfx-audio/SKILL.md tells us not to do.
##
## Reuse for enemies (epic_08-03): instance this scene, set `follow_game_state` to
## false, and call `set_hp()` from the unit's HealthComponent. Do not copy it.

## Bar size in TEXTURE pixels. Combined with `pixel_size` this decides how big the
## bar looks in the world — world size is `bar_size * pixel_size`.
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

## World units per texture pixel. Together with `bar_size` this is the real
## "how big is it on screen" knob.
@export var pixel_size: float = 0.003:
	set(value):
		pixel_size = maxf(value, 0.0001)
		_rebuild()

## How far above the unit's origin the bar floats, in world units.
@export var height_offset: float = 2.8:
	set(value):
		height_offset = value
		_rebuild()

## Colour at the top edge of the fill.
@export var color_top: Color = Color(0.45, 0.90, 0.35):
	set(value):
		color_top = value
		_rebuild()

## Colour at the bottom edge of the fill.
@export var color_bottom: Color = Color(0.16, 0.62, 0.18):
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

## Colour of the outline framing the bar. Alpha 0 removes it.
@export var rim_color: Color = Color(0.04, 0.04, 0.06):
	set(value):
		rim_color = value
		_rebuild()

## Outline thickness in TEXTURE pixels, and also how far the fill is inset. 0 = no rim.
##
## What matters is this as a FRACTION of `bar_size.y`, because that fraction is what
## survives to the screen. The bar is only ~12px tall in the editor preview window
## (~22px at the 1080x1920 target), so a rim at 7% of the height came out under one
## pixel and rounding landed it on the bottom edge and nothing on the top. At ~15%
## it clears a whole pixel on both edges. Raise this, not `bar_size`, if the outline
## still reads thin.
@export var rim_width: int = 7:
	set(value):
		rim_width = maxi(value, 0)
		_rebuild()

## Corner radius in TEXTURE pixels. At or above half the height = full capsule.
@export var corner_radius: int = 12:
	set(value):
		corner_radius = maxi(value, 0)
		_rebuild()

## Show the current health as a number on the bar, like the reference art.
@export var show_value: bool = true:
	set(value):
		show_value = value
		_rebuild()

## Size of that number.
@export var value_font_size: int = 48:
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

## Draw on top of everything, even when geometry would cover the bar. Leave this
## off unless the bar actually gets clipped by the model.
@export var always_on_top: bool = false:
	set(value):
		always_on_top = value
		_rebuild()

## When true the bar tracks the TOWER's health via GameState on its own, so the
## tower scenes need no script changes. Enemies set this false and call `set_hp()`.
@export var follow_game_state: bool = true

## Fill fraction shown in the editor only, so the look can be judged at a glance.
## Has no effect while the game is running.
@export_range(0.0, 1.0) var editor_preview_fill: float = 0.7:
	set(value):
		editor_preview_fill = clampf(value, 0.0, 1.0)
		_refresh()

var _track: Sprite3D
var _fill: Sprite3D
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


func _on_hp_changed(current: float, max_hp: float) -> void:
	set_hp(current, max_hp)


## Public API for any unit that drives its own health (enemies, bosses).
func set_hp(current: float, max_hp: float) -> void:
	if max_hp <= 0.0:
		return
	_max = max_hp
	_current = clampf(current, 0.0, max_hp)
	_refresh()


func _build_layers() -> void:
	if _track != null:
		return
	_track = _add_sprite("Track", 0)
	_fill = _add_sprite("Fill", 1)
	_value = Label3D.new()
	# Named so they are identifiable in the debugger's remote scene tree; without
	# this Godot auto-names them Sprite3D / Sprite3D2 / Sprite3D3.
	_value.name = "Value"
	_value.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_value.render_priority = 3
	_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_value, false, Node.INTERNAL_MODE_BACK)


## Size of the fill capsule: the bar inset by `rim_width` on every side, so the
## outline baked into the track is always left showing.
func _inner_size() -> Vector2i:
	return Vector2i(maxi(bar_size.x - rim_width * 2, 2), maxi(bar_size.y - rim_width * 2, 2))


func _add_sprite(node_name: String, priority: int) -> Sprite3D:
	var s := Sprite3D.new()
	s.name = node_name
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.render_priority = priority
	add_child(s, false, Node.INTERNAL_MODE_BACK)
	return s


func _rebuild() -> void:
	if not is_inside_tree():
		return
	_build_layers()

	position.y = height_offset

	# The outline is baked into the BOTTOM layer and the fill is inset inside it.
	# It is not a separate quad stacked on top: four billboarded sprites all sat at
	# the same depth, and `render_priority` did not reliably keep the rim above the
	# fill — so the green covered the outline along the flat top and bottom edges
	# while the rounded caps, where the fill curves inward, still showed it. Insetting
	# makes the outline geometrically unreachable, whatever the sort order does.
	_track.texture = BarTexture.make_capsule(
			bar_size, track_color_top, track_color_bottom, corner_radius,
			rim_color, rim_width)
	var inner := _inner_size()
	_fill.texture = BarTexture.make_capsule(
			inner, color_top, color_bottom, maxi(corner_radius - rim_width, 0))

	for s: Sprite3D in [_track, _fill]:
		s.pixel_size = pixel_size
		s.no_depth_test = always_on_top

	_value.visible = show_value
	_value.font_size = value_font_size
	_value.outline_size = maxi(value_font_size / 6, 1)
	_value.no_depth_test = always_on_top
	# The label is NOT supersampled the way the bar art is — Label3D rasterises its
	# own glyphs at `font_size`, so it stays crisp on its own. It only needs the
	# same world scale as the bar, hence plain `pixel_size`. `value_font_size` is
	# the knob for how big the number reads.
	_value.pixel_size = pixel_size
	# Lift it toward the bar's top edge. Expressed in bar heights so the offset
	# tracks bar_size and pixel_size instead of going stale when either changes.
	_value.position.y = bar_size.y * pixel_size * value_raise

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
	var inner := _inner_size()
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
