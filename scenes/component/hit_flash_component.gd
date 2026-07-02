class_name HitFlashComponent
extends Node

@export var mesh: MeshInstance3D

func _ready() -> void:
	var health := get_parent().find_child("HealthComponent") as HealthComponent
	if health:
		health.health_changed.connect(_on_health_changed)

func _on_health_changed(_current: float, _max_hp: float) -> void:
	pass # Full implementation Epic 06
