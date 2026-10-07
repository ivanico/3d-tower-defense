extends "res://scenes/component/tower_ult_component.gd"

## Poison's ult, Plague Cloud (09-13): a poison zone on the tower that hits
## every enemy inside each tick (plus Poison's DoT + slow). Star 3: bigger and
## longer. Star 5: an enemy dying inside spreads a hit to enemies near it.
## The zone is plague_cloud.tscn (extends the AoE Area zone), fed a
## SpellDefinition built from Constants.

const PLAGUE_CLOUD_SCENE := preload("res://scenes/game_object/plague_cloud/plague_cloud.tscn")


func _get_school() -> int:
	return Constants.DamageType.POISON


func _activate(tier: int) -> void:
	var spell := SpellDefinition.new()
	spell.spell_id = "ult_plague_cloud"
	spell.damage_type = Constants.DamageType.POISON
	# Base damage: the zone itself applies the tower's damage multiplier.
	spell.damage = Constants.PLAGUE_CLOUD_DAMAGE
	spell.aoe_radius = tier_value(Constants.PLAGUE_CLOUD_RADIUS)
	spell.duration = tier_value(Constants.PLAGUE_CLOUD_DURATION)
	spell.tick_interval = Constants.PLAGUE_CLOUD_TICK_SEC
	var cloud := ObjectPool.acquire(PLAGUE_CLOUD_SCENE)
	cloud.spread_on_death = tier >= 3
	cloud.initialize(Vector3(tower.global_position.x, 0.0, tower.global_position.z), spell)
