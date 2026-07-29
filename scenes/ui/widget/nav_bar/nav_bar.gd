@tool
extends Control

## Bottom navigation shared by every meta screen.
##
## Order is Garage · Worldmap · Codex, with Worldmap deliberately in the MIDDLE:
## the world map is what opens when the game starts, so it is the home position.
##
## Three square-cornered tiles sit flush against each other and fill the bar's
## whole width, over a dark frame. The entry you are on is wider, shaded tan
## instead of grey, and carries its name under the icon. Changing `selected` at
## runtime cross-fades and grows into that state rather than snapping — see
## `navigate_to()`.
##
## Every colour here was sampled off the reference art rather than guessed, so
## the defaults are the reference: grey tiles shading #ddd9cf → #eae8db over a
## flat #dedbd4 lower band, a 1px near-white line along the top that is what makes
## them read as shiny, and a selected tile running #c5966e at the top to #edd3b8
## at the bottom in one continuous fade.
##
## The tiles are NOT StyleBoxFlat: that has a single `bg_color` and cannot do a
## gradient at all, which is the entire look. They are generated textures — see
## `bar_texture.gd`'s `make_tile()` — stretched through a NinePatchRect.
##
## No artwork is involved beyond the three icons, which already exist in
## `assets/ui/nav/`.
##
## This is a plain Control that positions its buttons itself rather than an
## HBoxContainer, because a container will not let one child be wider or taller
## than its siblings, and that difference is the whole design.

const BarTexture := preload("res://scenes/ui/widget/bar_texture.gd")

enum Nav { GARAGE, WORLDMAP, CODEX }

## Which screen we are on. The matching tile grows, changes shade, shows its label
## and is disabled so the current screen cannot navigate to itself. Setting this at
## runtime plays the transition; setting it in the editor snaps.
@export var selected: Nav = Nav.WORLDMAP:
	set(value):
		var changed: bool = value != selected
		selected = value
		_apply(changed)

## Seconds the grow/cross-fade transition takes. 0 disables it.
@export var animation_time: float = 0.18:
	set(value):
		animation_time = maxf(value, 0.0)

@export_group("Frame")
## The dark strip the tiles sit on. Visible only as the border around them, so
## the three `frame_*` knobs below are what actually control how much you see.
@export var bar_color: Color = Color("272923"):
	set(value):
		bar_color = value
		_apply()

## 0 by default: the bar runs edge to edge, with no border down its left and right
## sides. Only the top and bottom are framed.
@export var frame_side: int = 0:
	set(value):
		frame_side = maxi(value, 0)
		_apply()

@export var frame_top: int = 2:
	set(value):
		frame_top = maxi(value, 0)
		_apply()

## The reference's frame is much thicker along the bottom than the top.
@export var frame_bottom: int = 13:
	set(value):
		frame_bottom = maxi(value, 0)
		_apply()

@export_group("Tile shading — unselected")
## Top of the upper gradient band.
@export var tile_color_top: Color = Color("ddd9cf"):
	set(value):
		tile_color_top = value
		_apply()

## Bottom of the upper gradient band.
@export var tile_color_split: Color = Color("eae8db"):
	set(value):
		tile_color_split = value
		_apply()

## The flat lower band. This second tone is what stops the tile looking like a
## single slab.
@export var tile_color_bottom: Color = Color("dedbd4"):
	set(value):
		tile_color_bottom = value
		_apply()

## Where the gradient band ends and the flat band starts, as a fraction of the
## tile's height. 1.0 = one gradient the whole way down, no flat band.
@export_range(0.0, 1.0, 0.01) var tile_split: float = 0.52:
	set(value):
		tile_split = clampf(value, 0.0, 1.0)
		_apply()

## The bright line along the very top of the tile — this is the shine.
@export var tile_highlight_color: Color = Color("f8f8f4"):
	set(value):
		tile_highlight_color = value
		_apply()

@export_group("Tile shading — selected")
@export var selected_color_top: Color = Color("c5966e"):
	set(value):
		selected_color_top = value
		_apply()

@export var selected_color_split: Color = Color("edd3b8"):
	set(value):
		selected_color_split = value
		_apply()

@export var selected_color_bottom: Color = Color("edd3b8"):
	set(value):
		selected_color_bottom = value
		_apply()

## 1.0 by default: the selected tile is ONE continuous fade, dark at the top and
## light at the bottom, with no second band.
@export_range(0.0, 1.0, 0.01) var selected_split: float = 1.0:
	set(value):
		selected_split = clampf(value, 0.0, 1.0)
		_apply()

@export var selected_highlight_color: Color = Color("e2c1a6"):
	set(value):
		selected_highlight_color = value
		_apply()

@export_group("Tiles")
## Height of the bright top line, shared by both looks.
@export var highlight_height: int = 4:
	set(value):
		highlight_height = maxi(value, 0)
		_apply()

## The seam between tiles. Drawn as its own strip at each INTERNAL boundary — two
## of them for three entries — so this is the exact width you see, and the outer
## sides of the bar stay clean. 0 removes the seams entirely.
@export var divider_width: int = 3:
	set(value):
		divider_width = maxi(value, 0)
		_apply()

@export var divider_color: Color = Color("272923"):
	set(value):
		divider_color = value
		_apply()

## How many pixels wider the selected tile is than an unselected one. The three
## tiles always add up to the bar's full inner width, so this only redistributes.
@export var selected_extra_width: int = 90:
	set(value):
		selected_extra_width = value
		_apply()

## How many pixels the selected tile pokes ABOVE the others. 0 = flush.
@export var selected_rise: int = 0:
	set(value):
		selected_rise = value
		_apply()

## Free nudge for the whole tile row, in pixels. Positive y moves it DOWN.
@export var row_offset: Vector2 = Vector2.ZERO:
	set(value):
		row_offset = value
		_apply()

@export_group("Icons")
## Icon edge length on the two entries you are NOT on.
@export var normal_icon_size: int = 104:
	set(value):
		normal_icon_size = maxi(value, 8)
		_apply()

## Icon edge length on the entry you ARE on.
@export var selected_icon_size: int = 124:
	set(value):
		selected_icon_size = maxi(value, 8)
		_apply()

## Free nudge for every icon, in pixels. Positive y moves them DOWN.
@export var icon_offset: Vector2 = Vector2.ZERO:
	set(value):
		icon_offset = value
		_apply()

@export_group("Labels")
## Reference behaviour: only the entry you are on is named. Turn this off to
## label all three.
@export var label_on_selected_only: bool = true:
	set(value):
		label_on_selected_only = value
		_apply()

@export var label_font_size: int = 34:
	set(value):
		label_font_size = maxi(value, 4)
		_apply()

## Both tiles are light, so both label colours are dark — but the tan tile takes a
## slightly warmer one.
@export var label_color: Color = Color("4a4038"):
	set(value):
		label_color = value
		_apply()

@export var label_color_selected: Color = Color("4a3627"):
	set(value):
		label_color_selected = value
		_apply()

## Gap between the bottom of the icon and the top of the word.
@export var label_gap: int = 4:
	set(value):
		label_gap = value
		_apply()

## Free nudge for the labels, in pixels. Positive y moves them DOWN.
@export var label_offset: Vector2 = Vector2.ZERO:
	set(value):
		label_offset = value
		_apply()


var _bar_panel: Panel
var _dividers: Array[ColorRect] = []
var _tween: Tween


func _ready() -> void:
	# Tile widths are a share of the bar's own rect, so re-run when that changes.
	if not resized.is_connected(_apply_static):
		resized.connect(_apply_static)
	# The seams snap to whole device pixels, which depends on the window size and
	# NOT on our own rect — the design space stays 1080x1920 however the window is
	# resized, so `resized` never fires for it.
	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_apply_static):
		viewport.size_changed.connect(_apply_static)
	_apply()


## Pixels on the actual display per unit of the 1080x1920 design space. Returns 0
## when it cannot be determined, which callers treat as "do not snap".
func _device_scale() -> float:
	var viewport := get_viewport()
	if viewport == null:
		return 0.0
	return viewport.get_final_transform().get_scale().x


## Selects `target`, lets the transition play, then swaps scene. Screens call this
## instead of change_scene_to_file directly — changing scene immediately would
## kill the tween on its first frame and you would never see it.
func navigate_to(target: Nav, scene_path: String) -> void:
	selected = target
	if animation_time > 0.0:
		await get_tree().create_timer(animation_time).timeout
	get_tree().change_scene_to_file(scene_path)


## Buttons in `Nav` order, so the enum indexes straight into this.
func _buttons() -> Array:
	return [
		get_node_or_null("GarageButton"),
		get_node_or_null("WorldmapButton"),
		get_node_or_null("CodexButton"),
	]


# `resized` passes no argument, and _apply's default must stay `false` there.
func _apply_static() -> void:
	_apply()


func _apply(animated: bool = false) -> void:
	if not is_inside_tree():
		return
	var buttons := _buttons()
	for b in buttons:
		if b == null:
			return

	_style_bar_panel()

	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null

	var inner_origin := Vector2(frame_side, frame_top)
	var inner := Vector2(
			size.x - float(frame_side * 2),
			size.y - float(frame_top + frame_bottom))
	# The three tiles are sized to add up to exactly the inner width, so the
	# selected one absorbs the rounding rather than leaving a seam at the edge.
	var normal_w: float = floorf((inner.x - float(selected_extra_width)) / 3.0)
	var selected_w: float = inner.x - normal_w * 2.0

	# Rasterised once per layout, then shared by all three buttons — the tiles
	# differ only in which of the two is faded in.
	var normal_texture := BarTexture.make_tile(int(inner.y),
			tile_color_top, tile_color_split, tile_color_bottom, tile_split,
			tile_highlight_color, highlight_height)
	var selected_texture := BarTexture.make_tile(int(inner.y) + selected_rise,
			selected_color_top, selected_color_split, selected_color_bottom,
			selected_split, selected_highlight_color, highlight_height)

	var do_animate: bool = animated and not Engine.is_editor_hint() and animation_time > 0.0
	if do_animate:
		_tween = create_tween().set_parallel(true)
		_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	var x: float = inner_origin.x
	var seams: Array[float] = []
	for i in buttons.size():
		var button: Button = buttons[i]
		var is_selected: bool = i == selected
		var tile_w: float = selected_w if is_selected else normal_w
		var rise: float = float(selected_rise) if is_selected else 0.0

		var target_position := Vector2(x, inner_origin.y - rise) + row_offset
		var target_size := Vector2(tile_w, inner.y + rise)
		var target_icon: float = float(selected_icon_size if is_selected else normal_icon_size)
		var show_label: bool = is_selected or not label_on_selected_only

		button.set_tile_art(normal_texture, selected_texture, highlight_height)
		button.set_content(icon_offset, show_label, label_gap, label_font_size,
				label_color_selected if is_selected else label_color, label_offset)
		button.disabled = is_selected

		if do_animate:
			_tween.tween_property(button, "position", target_position, animation_time)
			_tween.tween_property(button, "size", target_size, animation_time)
			_tween.tween_property(button, "icon_px", target_icon, animation_time)
			_tween.tween_property(button, "bg_blend", 1.0 if is_selected else 0.0,
					animation_time)
			_tween.tween_property(button, "label_alpha", 1.0 if show_label else 0.0,
					animation_time)
		else:
			button.position = target_position
			button.size = target_size
			button.icon_px = target_icon
			button.bg_blend = 1.0 if is_selected else 0.0
			button.label_alpha = 1.0 if show_label else 0.0

		x += tile_w
		if i < buttons.size() - 1:
			seams.append(x)

	_place_dividers(seams, inner_origin.y + row_offset.y, inner.y, do_animate)


## Seams are separate strips rather than part of the tile art, so they appear only
## BETWEEN entries — a border baked into the tiles would also run down the outer
## sides of the bar, and the bar has to reach both screen edges.
##
## Each strip is snapped to whole DEVICE pixels. Without that the two seams render
## visibly different widths: the design space is 1080 wide but the window is not,
## so a 3-unit strip is ~1.4 real pixels, and whether that covers one pixel centre
## or two comes down to where it happens to land. The two seams sit symmetrically
## about the bar's centre, so their fractional offsets are mirror images and they
## round OPPOSITE ways — one seam 2px, the other 1px. Snapping makes both exactly
## `round(divider_width * scale)` pixels, aligned to the grid.
func _place_dividers(seams: Array[float], top: float, height: float,
		animated: bool) -> void:
	while _dividers.size() < seams.size():
		var strip := ColorRect.new()
		strip.name = "Divider%d" % _dividers.size()
		strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# INTERNAL_MODE_BACK sits after the buttons in the child list, so the seam
		# paints over the tiles instead of under them.
		add_child(strip, false, Node.INTERNAL_MODE_BACK)
		_dividers.append(strip)

	var scale := _device_scale()
	for i in _dividers.size():
		var strip := _dividers[i]
		strip.visible = i < seams.size() and divider_width > 0
		if not strip.visible:
			continue
		strip.color = divider_color

		# Straddles the boundary so neither neighbour loses more than the other.
		var centre: float = seams[i] + row_offset.x
		var left: float = centre - divider_width * 0.5
		var width: float = float(divider_width)
		if scale > 0.0:
			width = maxf(roundf(width * scale), 1.0) / scale
			left = roundf(centre * scale - width * scale * 0.5) / scale

		strip.size = Vector2(width, height)
		var target := Vector2(left, top)
		if animated and _tween != null:
			_tween.tween_property(strip, "position", target, animation_time)
		else:
			strip.position = target


func _style_bar_panel() -> void:
	if _bar_panel == null:
		# INTERNAL_MODE_FRONT puts it before the buttons in the child list, so it
		# paints behind them. It is never written into a .tscn.
		_bar_panel = Panel.new()
		_bar_panel.name = "BarPanel"
		_bar_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_bar_panel, false, Node.INTERNAL_MODE_FRONT)
	_bar_panel.position = Vector2.ZERO
	_bar_panel.size = size

	var box := StyleBoxFlat.new()
	box.bg_color = bar_color
	_bar_panel.add_theme_stylebox_override("panel", box)
