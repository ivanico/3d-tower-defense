class_name TargetingComponent
extends Node

## Every spell type targets a RANDOM enemy in range, no exceptions (Orb
## doesn't use this at all -- it orbits and hits on contact instead of
## targeting). There used to be a `mode` export (CLOSEST/RANDOM) here, but
## `get_targets()` -- the function tower.gd actually fires every projectile
## through, stacked or not -- never read it and was unconditionally
## nearest-first sorted, so every projectile spell always hit the closest
## enemy regardless of what `mode` said. `get_target()` was the only thing
## that respected `mode`, and its result was only ever used as a null-check,
## never for the real pick. Removed `mode`/`TargetMode.CLOSEST` entirely
## instead of just fixing the sort, so there's no dormant, silently-unwired
## "closest" path left for a future change to accidentally wake back up --
## both entry points below now share the exact same random selection.

@export var range: float = 8.0

var _enemies_in_range: Array[Node3D] = []

func _ready() -> void:
	var range_area := get_parent().get_node_or_null("AttackRangeArea") as Area3D
	if range_area:
		range_area.body_entered.connect(_on_range_entered)
		range_area.body_exited.connect(_on_range_exited)

func _on_range_entered(body: Node3D) -> void:
	if body.is_in_group("enemies") and not _enemies_in_range.has(body):
		_enemies_in_range.append(body)

func _on_range_exited(body: Node3D) -> void:
	_enemies_in_range.erase(body)

func get_target(max_distance: float = INF) -> Node3D:
	var targets := get_targets(1, max_distance)
	return targets[0] if not targets.is_empty() else null

# Up to `count` distinct RANDOM targets in range -- used by every projectile
# cast (spells.md Task S-01's volley stacking included: tower.gd routes
# every Standard/Chain/Line-AoE Bolt cast through this, stacked or not,
# count==1 for a plain unstacked shot).
func get_targets(count: int, max_distance: float = INF) -> Array[Node3D]:
	var targetable := _get_targetable(max_distance)
	targetable.shuffle()
	var result: Array[Node3D] = []
	for i in mini(count, targetable.size()):
		result.append(targetable[i])
	return result

func _get_targetable(max_distance: float) -> Array[Node3D]:
	_enemies_in_range = _enemies_in_range.filter(func(e): return is_instance_valid(e))
	var owner_node := get_parent() as Node3D
	return _enemies_in_range.filter(func(e):
		return _is_on_screen(e) and owner_node.global_position.distance_to(e.global_position) <= max_distance)

func _is_on_screen(enemy: Node3D) -> bool:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return true
	return camera.is_position_in_frustum(enemy.global_position)
