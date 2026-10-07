extends "res://scenes/component/tower_ult_component.gd"

## Void's ult, Void Rupture (09-13): Void damage to every on-screen enemy,
## bosses included. Star 3: more damage. Star 5: the tower gets a shield equal
## to the damage dealt (capped at a % of max HP), for Barkskin's longest time.

func _get_school() -> int:
	return Constants.DamageType.VOID


func _activate(tier: int) -> void:
	var dealt := 0.0
	var dmg := scaled_damage(tier_value(Constants.VOID_RUPTURE_DAMAGE))
	for enemy in CombatUtils.get_enemies_on_screen(get_tree()):
		var hurtbox: Node = enemy.find_child("HurtboxComponent")
		if hurtbox:
			dealt += hurtbox.apply_hit(dmg, Constants.DamageType.VOID, enemy.global_position + Vector3(0, 0.6, 0))
	if tier >= 3 and dealt > 0.0:
		var cap := GameState.tower_max_hp * Constants.VOID_RUPTURE_SHIELD_CAP_PERCENT
		GameState.add_shield(minf(dealt, cap), Constants.BARKSKIN_DURATION[2])
