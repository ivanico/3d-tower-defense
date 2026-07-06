class_name BossHeavyAttackComponent
extends Node

var _attack_count: int = 0

func perform_attack(base_damage: float) -> void:
	_attack_count += 1
	if _attack_count % Constants.BOSS_HEAVY_ATTACK_EVERY_N == 0:
		_heavy_attack(base_damage)
	else:
		GameState.take_damage(base_damage)

func _heavy_attack(base_damage: float) -> void:
	_telegraph()
	await get_tree().create_timer(Constants.BOSS_HEAVY_ATTACK_TELEGRAPH_SEC).timeout
	if not is_instance_valid(self):
		return
	GameState.take_damage(base_damage * Constants.BOSS_HEAVY_ATTACK_DAMAGE_MULT)

func _telegraph() -> void:
	var parent := get_parent() as Node3D
	var base_scale: Vector3 = parent.scale
	var tween := parent.create_tween()
	var half := Constants.BOSS_HEAVY_ATTACK_TELEGRAPH_SEC * 0.5
	tween.tween_property(parent, "scale", base_scale * 1.15, half)
	tween.tween_property(parent, "scale", base_scale, half)
