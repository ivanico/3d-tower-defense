extends CharacterBody3D
class_name Tower

@export var definition: TowerDefinition

@onready var health: HealthComponent = $HealthComponent
@onready var targeting: TargetingComponent = $TargetingComponent

func _ready() -> void:
	add_to_group("tower")
	if definition != null:
		health.max_health = definition.base_hp
		health.current_health = definition.base_hp
		GameState.start_run(definition)

func _fire_spell() -> void:
	pass # Real wiring Epic 02
