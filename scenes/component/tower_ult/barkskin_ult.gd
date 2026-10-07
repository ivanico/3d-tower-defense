extends "res://scenes/component/tower_ult_component.gd"

## Ancient's ult, Barkskin (09-13): a shield worth a % of max HP. Enemy hits
## drain it before HP (GameState.take_damage). Star 3: bigger and longer.
## Star 5: whatever is left when it runs out heals the tower.

func _get_school() -> int:
	return Constants.DamageType.NATURE


func _activate(tier: int) -> void:
	GameState.add_shield(
			GameState.tower_max_hp * tier_value(Constants.BARKSKIN_SHIELD_PERCENT),
			tier_value(Constants.BARKSKIN_DURATION),
			tier >= 3)
