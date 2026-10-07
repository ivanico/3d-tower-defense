@tool  # redeclared on purpose: see rain_of_fire.gd's note on @tool and inheritance.
extends "res://scenes/game_object/aoe_area/aoe_area.gd"

## Poison's ult zone, Plague Cloud (09-13). Everything from aoe_area.gd (the
## decal, the body_entered list, the tick that hits every enemy inside through
## apply_hit, so Poison's DoT + slow and the armor table apply) except:
## - no falling shards: the cloud is the decal alone.
## - star 5 (`spread_on_death`): when an enemy dies inside the cloud, every
##   enemy within Constants.PLAGUE_CLOUD_SPREAD_RADIUS of it takes one cloud hit.
## Placed on the tower by plague_cloud_ult.gd, with a SpellDefinition built from
## Constants (damage, radius, duration, tick).

var spread_on_death: bool = false


func _ready() -> void:
	super()
	if not Engine.is_editor_hint():
		EventBus.enemy_died.connect(_on_enemy_died)


func _spawn_shard() -> void:
	pass


func _on_enemy_died(_enemy: Node, death_pos: Vector3) -> void:
	if not _active or not spread_on_death:
		return
	var flat := Vector2(death_pos.x - global_position.x, death_pos.z - global_position.z)
	if flat.length() > radius:
		return
	for other in get_tree().get_nodes_in_group("enemies"):
		if other.global_position.distance_to(death_pos) <= Constants.PLAGUE_CLOUD_SPREAD_RADIUS:
			_hit(other)


func reset() -> void:
	super()
	spread_on_death = false
