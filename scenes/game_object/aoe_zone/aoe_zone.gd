extends Area3D

var damage: float = 0.0
var damage_type: int = Constants.DamageType.NORMAL
var _radius: float = 1.0

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func initialize(pos: Vector3, radius: float, spell: SpellDefinition) -> void:
	global_position = pos
	damage = spell.damage * GameState.tower_damage_multiplier * GameState.offense_damage_mult
	damage_type = spell.damage_type
	_radius = radius
	mesh_instance.scale = Vector3(radius, 1.0, radius)
	_burst()

func _burst() -> void:
	_apply_damage()
	await get_tree().create_timer(0.3).timeout
	ObjectPool.release(self)

func _apply_damage() -> void:
	var hit_count := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if global_position.distance_to(enemy.global_position) <= _radius:
			var hurtbox := enemy.find_child("HurtboxComponent") as HurtboxComponent
			if hurtbox:
				hurtbox.apply_hit(damage, damage_type)
				hit_count += 1

func reset() -> void:
	damage = 0.0
	damage_type = Constants.DamageType.NORMAL
	_radius = 1.0
