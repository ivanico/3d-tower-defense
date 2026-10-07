extends "res://scenes/component/tower_ult_component.gd"

## Frost's ult, the freeze (09-13): roots every on-screen enemy. They can't
## move but keep attacking (a snare, not a stun). Bosses are immune.
## Star 3: longer. Star 5: each rooted enemy also takes a Frost hit.

func _get_school() -> int:
	return Constants.DamageType.FROST


func _activate(tier: int) -> void:
	var root_sec := tier_value(Constants.FROST_ULT_ROOT_SEC)
	for enemy in CombatUtils.get_enemies_on_screen(get_tree()):
		if enemy.definition != null and enemy.definition.is_boss:
			continue
		var status: Node = enemy.find_child("StatusEffectComponent")
		if status:
			status.apply_root(root_sec)
		if tier >= 3:
			var hurtbox: Node = enemy.find_child("HurtboxComponent")
			if hurtbox:
				hurtbox.apply_hit(scaled_damage(Constants.FROST_ULT_STAR5_DAMAGE),
						Constants.DamageType.FROST, enemy.global_position + Vector3(0, 0.6, 0))
