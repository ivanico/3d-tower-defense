@tool
extends Button

## One cell of the garage's tower grid: the tower's icon on a framed plate, its
## stars underneath, and a highlighted border when it is the one you have picked.
##
## A tower that is not yet real content (`TowerDefinition.unlocked == false`)
## draws the same icon desaturated by `greyscale.gdshader` with a padlock over it.
## No grey copy of any artwork has to exist — `modulate` cannot desaturate, only
## tint, so it has to be a shader.
##
## Everything is built in code as internal children, and `_validate_property`
## strips the generated theme overrides, so instancing this into the garage bakes
## nothing into that scene. See the note in nav_button.gd for why that matters.

const LOCK_TEXTURE := preload("res://assets/ui/world_map/ui_locked_overlay.png")
const GREYSCALE_SHADER := preload("res://scenes/ui/widget/tower_slot/greyscale.gdshader")
const StarRowScene := preload("res://scenes/ui/widget/star_row/star_row.tscn")

## Alpha at which a pixel counts as part of the card frame when measuring it.
const ART_ALPHA := 0.5

## Emitted instead of `pressed` so the grid does not have to know which cell is
## which — it binds the tower id.
signal slot_pressed

@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		_measure_art()
		if _icon != null:
			_icon.texture = value
		_apply()

## Real content, or a placeholder holding a grid position. Locked slots grey out,
## show the padlock, hide their stars and ignore presses.
@export var locked: bool = false:
	set(value):
		locked = value
		_apply()

## Highlighted ring. The garage sets this on exactly one slot.
@export var selected: bool = false:
	set(value):
		selected = value
		_apply()

@export_group("Selection ring")
## The ring is drawn on its own node sized to the ARTWORK, not to the cell.
##
## `icon_tower_ancient.png` is already a finished card — stone-and-gold frame,
## teal backdrop — and its opaque pixels stop ~5% short of the PNG's edge. A
## border on the Button's rect therefore floats a dozen pixels outside the frame
## the art already has, reading as a stray rectangle rather than a selection.
@export var ring_color: Color = Color("4ee34e"):
	set(value):
		ring_color = value
		_apply()

@export var ring_width: int = 6:
	set(value):
		ring_width = maxi(value, 0)
		_apply()

## Corner rounding of the ring, as a fraction of its own width — NOT pixels, so it
## stays matched to the artwork whatever size the grid makes the cells.
## `icon_tower_ancient.png`'s frame is rounded at 19% of its width (measured off
## the alpha), which is why a flat 18px looked square against it.
@export_range(0.0, 0.5, 0.005) var ring_corner_radius: float = 0.19:
	set(value):
		ring_corner_radius = clampf(value, 0.0, 0.5)
		_apply()

@export var stars: int = 1:
	set(value):
		stars = value
		_apply()

@export_group("Plate")
## Transparent by default: the reference shows the artwork alone, not an icon
## floating on a card. Give it an alpha if you ever want the card back.
@export var plate_color: Color = Color(0, 0, 0, 0):
	set(value):
		plate_color = value
		_apply()

## Also transparent — with no plate there is nothing to frame. The SELECTED border
## is the only one that draws, which is what makes the picked tower readable.
@export var border_color: Color = Color(0, 0, 0, 0):
	set(value):
		border_color = value
		_apply()

@export var border_color_selected: Color = Color("ffc94a"):
	set(value):
		border_color_selected = value
		_apply()

@export var border_width: int = 4:
	set(value):
		border_width = maxi(value, 0)
		_apply()

@export var border_width_selected: int = 4:
	set(value):
		border_width_selected = maxi(value, 0)
		_apply()

@export var corner_radius: int = 18:
	set(value):
		corner_radius = maxi(value, 0)
		_apply()

@export_group("Contents")
## Icon edge length, as a fraction of the slot's SHORTER side, so the artwork
## keeps its proportions whatever the grid resizes cells to.
@export_range(0.1, 1.0, 0.01) var icon_fill: float = 0.94:
	set(value):
		icon_fill = clampf(value, 0.1, 1.0)
		_apply()

## Free nudge for the icon, in pixels. Positive y moves it DOWN.
@export var icon_offset: Vector2 = Vector2.ZERO:
	set(value):
		icon_offset = value
		_apply()

## Padlock size, as a fraction of the icon's size.
@export_range(0.1, 1.5, 0.01) var lock_fill: float = 0.52:
	set(value):
		lock_fill = clampf(value, 0.1, 1.5)
		_apply()

@export var star_size: int = 26:
	set(value):
		star_size = maxi(value, 4)
		_apply()

## Distance from the bottom of the slot up to the star row. Keep it clear of the
## selection ring's bottom band, or the stars sit on top of it and that edge of the
## ring reads thinner than the other three.
@export var star_margin_bottom: int = 30:
	set(value):
		star_margin_bottom = value
		_apply()

## How much the greyed-out artwork is darkened. 1.0 = grey but same brightness.
@export_range(0.0, 2.0, 0.01) var locked_brightness: float = 0.75:
	set(value):
		locked_brightness = clampf(value, 0.0, 2.0)
		_apply()

## Where the icon's CARD FRAME sits inside its texture, as fractions of the
## texture size, so the selection ring can be an even band around it.
##
## Found by scanning the centre row and centre column only — NOT
## `Image.get_used_rect()`. That scans the whole image, and the tower's crystal
## spire pokes above the card frame, so it reported the top margin as 13px when
## the frame's real margin is 48px and the ring ended up far too thick on top.
## The centre lines cross the frame and nothing else.
var _art := Rect2(0.0, 0.0, 1.0, 1.0)

var _icon: TextureRect
var _ring: Panel
var _lock: TextureRect
var _star_row: HBoxContainer
var _grey_material: ShaderMaterial


func _init() -> void:
	_build_children()


func _ready() -> void:
	_measure_art()
	if not resized.is_connected(_apply):
		resized.connect(_apply)
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	_apply()


func _validate_property(property: Dictionary) -> void:
	if property.name.begins_with("theme_override_"):
		property.usage &= ~PROPERTY_USAGE_STORAGE


func _build_children() -> void:
	if _icon != null:
		return
	_grey_material = ShaderMaterial.new()
	_grey_material.shader = GREYSCALE_SHADER

	# Added FIRST so it paints BEHIND the icon. It is a filled rounded rect slightly
	# larger than the artwork, so what shows is a coloured frame poking out around
	# the card. Drawing it on top instead laid a line across the artwork's bottom.
	_ring = Panel.new()
	_ring.name = "SelectionRing"
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ring, false, Node.INTERNAL_MODE_BACK)

	_icon = TextureRect.new()
	_icon.name = "Icon"
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.texture = icon_texture
	add_child(_icon, false, Node.INTERNAL_MODE_BACK)

	_star_row = StarRowScene.instantiate()
	_star_row.name = "Stars"
	_star_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_star_row, false, Node.INTERNAL_MODE_BACK)

	# Added last so the padlock sits above both the icon and the stars.
	_lock = TextureRect.new()
	_lock.name = "Lock"
	_lock.texture = LOCK_TEXTURE
	_lock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_lock.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_lock, false, Node.INTERNAL_MODE_BACK)


func _measure_art() -> void:
	_art = Rect2(0.0, 0.0, 1.0, 1.0)
	if icon_texture == null:
		return
	var image := icon_texture.get_image()
	if image == null:
		return
	if image.is_compressed():
		image.decompress()
	var w := image.get_width()
	var h := image.get_height()
	if w < 4 or h < 4:
		return
	# Horizontal edges from the middle row — nothing sticks out sideways there.
	var mid_y := h / 2
	var left := 0
	while left < w - 1 and image.get_pixel(left, mid_y).a < ART_ALPHA:
		left += 1
	var right := w - 1
	while right > left and image.get_pixel(right, mid_y).a < ART_ALPHA:
		right -= 1

	# Vertical edges from a column 15% in from the frame's left edge, NOT the
	# middle: the tower's crystal spire is dead centre and pokes above the frame,
	# so a centre column measures the spire and lifts the ring's top band.
	var probe_x: int = left + int((right - left) * 0.15)
	var top := 0
	while top < h - 1 and image.get_pixel(probe_x, top).a < ART_ALPHA:
		top += 1
	var bottom := h - 1
	while bottom > top and image.get_pixel(probe_x, bottom).a < ART_ALPHA:
		bottom -= 1
	if right <= left or bottom <= top:
		return
	_art = Rect2(float(left) / w, float(top) / h,
			float(right - left + 1) / w, float(bottom - top + 1) / h)


func _on_pressed() -> void:
	if locked:
		return
	slot_pressed.emit()


func _apply() -> void:
	if not is_inside_tree() or _icon == null:
		return

	var plate := StyleBoxFlat.new()
	plate.bg_color = plate_color
	plate.border_color = border_color
	var width: int = border_width
	plate.border_width_left = width
	plate.border_width_top = width
	plate.border_width_right = width
	plate.border_width_bottom = width
	plate.corner_radius_top_left = corner_radius
	plate.corner_radius_top_right = corner_radius
	plate.corner_radius_bottom_left = corner_radius
	plate.corner_radius_bottom_right = corner_radius
	focus_mode = Control.FOCUS_NONE
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(state, plate)

	# Disabled rather than just ignored, so a locked slot does not take the press
	# animation either.
	disabled = locked

	var icon_px: float = minf(size.x, size.y) * icon_fill
	_icon.size = Vector2(icon_px, icon_px)
	_icon.position = (size - _icon.size) * 0.5 + icon_offset
	_icon.material = _grey_material if locked else null
	if locked:
		_grey_material.set_shader_parameter("amount", 1.0)
		_grey_material.set_shader_parameter("brightness", locked_brightness)

	# Sized to the ARTWORK's opaque rect, then grown by `ring_width` on every side,
	# so the visible band is exactly that thick all the way round. Filled rather
	# than outlined because it sits BEHIND the card, which covers the middle.
	_ring.visible = selected
	if selected:
		var band := Vector2(ring_width, ring_width)
		_ring.position = _icon.position + _art.position * icon_px - band
		_ring.size = _art.size * icon_px + band * 2.0
		var ring_box := StyleBoxFlat.new()
		ring_box.bg_color = ring_color
		ring_box.set_corner_radius_all(int(round(_ring.size.x * ring_corner_radius)))
		_ring.add_theme_stylebox_override("panel", ring_box)

	_lock.visible = locked
	var lock_px: float = icon_px * lock_fill
	_lock.size = Vector2(lock_px, lock_px)
	_lock.position = (size - _lock.size) * 0.5 + icon_offset

	_star_row.visible = not locked
	_star_row.star_size = star_size
	_star_row.stars = stars
	# Width is five stars plus the row's own separation between them.
	var separation: int = _star_row.get_theme_constant("separation")
	var row_w: float = star_size * 5 + separation * 4
	_star_row.size = Vector2(row_w, star_size)
	_star_row.position = Vector2((size.x - row_w) * 0.5,
			size.y - star_size - star_margin_bottom)
