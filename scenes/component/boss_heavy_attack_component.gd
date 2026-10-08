class_name BossHeavyAttackComponent
extends Node

## 09-16: BossPhaseComponent turns this off for phase 1. While off, every
## attack is a normal hit. Stays true on a boss without a phase component.
var heavy_enabled: bool = true

var _attack_count: int = 0

## Restarts the "every Nth attack" count, so the first heavy hit lands N
## attacks after the switch (and a pooled boss starts fresh).
func set_heavy_enabled(enabled: bool) -> void:
	heavy_enabled = enabled
	_attack_count = 0

func perform_attack(base_damage: float, anim: AnimationPlayer = null) -> void:
	if not heavy_enabled:
		GameState.take_damage(base_damage)
		return
	_attack_count += 1
	if _attack_count % Constants.BOSS_HEAVY_ATTACK_EVERY_N == 0:
		_heavy_attack(base_damage, anim)
	else:
		GameState.take_damage(base_damage)

func _heavy_attack(base_damage: float, anim: AnimationPlayer = null) -> void:
	if anim:
		anim.play("attack_heavy")
	telegraph()
	await get_tree().create_timer(Constants.BOSS_HEAVY_ATTACK_TELEGRAPH_SEC).timeout
	if not is_instance_valid(self):
		return
	GameState.take_damage(base_damage * Constants.BOSS_HEAVY_ATTACK_DAMAGE_MULT)

## Scale pulse on the boss. Also the phase-change tell (BossPhaseComponent).
func telegraph() -> void:
	var parent := get_parent() as Node3D
	var base_scale: Vector3 = parent.scale
	var tween := parent.create_tween()
	var half := Constants.BOSS_HEAVY_ATTACK_TELEGRAPH_SEC * 0.5
	tween.tween_property(parent, "scale", base_scale * 1.15, half)
	tween.tween_property(parent, "scale", base_scale, half)
