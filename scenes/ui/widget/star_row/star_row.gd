@tool
extends HBoxContainer

## Row of five stars. Used at full size under the garage's 3D preview and shrunk
## down inside each grid slot — hence `star_size`, so one widget covers both
## rather than a second copy existing at a different scale.

const STAR_FILLED := preload("res://assets/ui/garage/ui_star_filled.png")
const STAR_EMPTY := preload("res://assets/ui/garage/ui_star_empty.png")

@export var stars: int = 1:
	set(value):
		stars = value
		_apply()

## Edge length of one star, in pixels.
@export var star_size: int = 38:
	set(value):
		star_size = maxi(value, 4)
		_apply()


func _ready() -> void:
	_apply()


func set_stars(value: int) -> void:
	stars = value


func _apply() -> void:
	if not is_inside_tree():
		return
	var index := 0
	for child in get_children():
		if child is TextureRect:
			child.texture = STAR_FILLED if index < stars else STAR_EMPTY
			child.custom_minimum_size = Vector2(star_size, star_size)
			child.size = Vector2(star_size, star_size)
			index += 1
