@tool  # NOT inherited from aoe_area.gd -- GDScript requires every script in
# the chain to redeclare @tool itself for the preview_school setter to
# actually run when rain_of_fire.tscn itself is opened in the editor (same
# gotcha standard_bolt.gd notes for spell_projectile_base.gd).
extends "res://scenes/game_object/aoe_area/aoe_area.gd"

## Rain of Fire's AoE-Area effect. Inherits everything from aoe_area.gd
## (spawn/tick/expire/decal/shard-drop logic) except:
## - shard landing effect: no impact burst — shards land silently, no
##   "break" FX, per design.
## - shard fall path: spawns offset to the right of where it lands (mirror
##   of Blizzard's left-side offset), so it reads as falling in from the
##   opposite side.

@export var shard_side_offset: float = 1.5 # meters, spawn point offset to the right (+X) of the landing spot (1.5m over the 3m drop height ≈ 27° off vertical, ≈ 63° from horizontal)

func _get_shard_spawn_position(ground: Vector3) -> Vector3:
	return ground + Vector3(shard_side_offset, SHARD_DROP_HEIGHT, 0)

# Still stops the shard's own SchoolVFXComponent on landing (see
# aoe_area.gd's own _on_shard_landed doc comment) -- that's invisible
# cleanup, not a "break" FX, so it doesn't conflict with the no-burst design
# intent above.
func _on_shard_landed(vfx: SchoolVFXComponent, _local_pos: Vector3) -> void:
	if is_instance_valid(vfx):
		vfx.stop()
