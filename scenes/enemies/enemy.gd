extends CharacterBody3D
class_name Enemy

@export var definition: EnemyDefinition

@onready var health: HealthComponent = $HealthComponent
@onready var mover: MoveToTargetComponent = $MoveToTargetComponent
@onready var melee_area: Area3D = $MeleeRangeArea

func _ready() -> void:
	add_to_group("enemies")
	_apply_definition()
	melee_area.body_entered.connect(_on_melee_range_body_entered)

func reset() -> void:
	_apply_definition()
	health.reset()

func _apply_definition() -> void:
	if definition == null:
		return
	health.max_health = definition.base_hp
	health.current_health = definition.base_hp
	mover.speed = definition.base_speed
	mover.hold_height = definition.hold_height
	var tower := get_tree().get_first_node_in_group("tower")
	if tower:
		mover.target_position = tower.global_position

func _on_melee_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("tower"):
		mover.speed = 0.0
