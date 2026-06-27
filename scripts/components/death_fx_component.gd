class_name DeathFXComponent
extends Node

func _ready() -> void:
	var health := get_parent().find_child("HealthComponent") as HealthComponent
	if health:
		health.died.connect(_on_died)

func _on_died() -> void:
	get_parent().queue_free() # Replaced with ObjectPool.release() in Epic 02
