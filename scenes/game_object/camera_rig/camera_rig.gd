class_name CameraRig
extends Node3D

@export var camera_pitch_degrees: float = Constants.CAMERA_PITCH_DEGREES
@export var camera_distance: float = 24.0
@export var camera_height: float = 24.0
@export var camera_fov: float = 30.0

@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	camera.position = Vector3(0.0, camera_height, camera_distance)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	camera.fov = camera_fov

func shake(duration: float, magnitude: float) -> void:
	var tween := create_tween()
	var original_pos := camera.position
	var elapsed := 0.0
	while elapsed < duration:
		var offset := Vector3(randf_range(-magnitude, magnitude), randf_range(-magnitude, magnitude), 0.0)
		tween.tween_property(camera, "position", original_pos + offset, 0.05)
		elapsed += 0.05
	tween.tween_property(camera, "position", original_pos, 0.1)
