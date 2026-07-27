extends HBoxContainer

const STAR_FILLED := preload("res://assets/ui/garage/ui_star_filled.png")
const STAR_EMPTY := preload("res://assets/ui/garage/ui_star_empty.png")

@export var stars: int = 1:
	set(value):
		stars = value
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
			index += 1
