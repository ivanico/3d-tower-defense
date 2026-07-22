extends "res://scenes/game_object/aoe_area/aoe_area.gd"

## Blizzard's AoE-Area effect. Inherits everything from aoe_area.gd except
## the shard fall path, overridden below: shards still land anywhere across
## the whole circle, but each one spawns offset to the left of where it
## lands (instead of straight above) and tilts to match — reads as falling
## in from the side and slamming into the ground at an angle, not straight.

@export var shard_side_offset: float = 1.5 # meters, spawn point offset to the left (-X) of the landing spot (1.5m over the 3m drop height ≈ 27° off vertical, ≈ 63° from horizontal)

func _get_shard_spawn_position(ground: Vector3) -> Vector3:
	return ground + Vector3(-shard_side_offset, SHARD_DROP_HEIGHT, 0)
