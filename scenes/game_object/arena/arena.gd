@tool
class_name Arena
extends StaticBody3D

@export var color_1: Color = Color(0.6, 0.78, 0.24, 1):
	set(value):
		color_1 = value
		_apply_colors()
@export var color_2: Color = Color(0.66, 0.82, 0.28, 1):
	set(value):
		color_2 = value
		_apply_colors()
@export var color_3: Color = Color(0.7, 0.85, 0.34, 1):
	set(value):
		color_3 = value
		_apply_colors()
@export var color_4: Color = Color(0.56, 0.74, 0.22, 1):
	set(value):
		color_4 = value
		_apply_colors()

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	_apply_colors()

func _apply_colors() -> void:
	if not is_inside_tree():
		return
	var mat := mesh_instance.get_surface_override_material(0) as ShaderMaterial
	if mat == null:
		return
	mat.set_shader_parameter("color_1", color_1)
	mat.set_shader_parameter("color_2", color_2)
	mat.set_shader_parameter("color_3", color_3)
	mat.set_shader_parameter("color_4", color_4)
