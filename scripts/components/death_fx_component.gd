class_name DeathFXComponent
extends Node

func _ready() -> void:
	var health := get_parent().find_child("HealthComponent") as HealthComponent
	if health:
		health.died.connect(_on_died)

func _on_died() -> void:
	var tween := get_parent().create_tween()
	tween.tween_property(get_parent(), "scale", Vector3(0.001, 0.001, 0.001), 0.25)
	tween.tween_callback(func(): get_parent().queue_free())
