class_name HealthComponent
extends Node

@export var max_health: float = 100.0
var current_health: float = 100.0

signal health_changed(current: float, max_hp: float)
signal died

func _ready() -> void:
	current_health = max_health

func damage(amount: float) -> void:
	if current_health <= 0.0:
		return
	current_health = max(current_health - amount, 0.0)
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0:
		call_deferred("_die")

func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func reset() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

func _die() -> void:
	died.emit()
