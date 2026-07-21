class_name TargetingComponent
extends Node

@export var range: float = 8.0
@export var mode: int = Constants.TargetMode.RANDOM

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
	var targetable := _get_targetable(max_distance)
	match mode:
		Constants.TargetMode.CLOSEST:
			return _closest_of(targetable)
		Constants.TargetMode.RANDOM:
			return _random_of(targetable)
	return null

# Up to `count` distinct targets, nearest first — used by volley-stacked
# spells (spells.md Task S-01).
func get_targets(count: int, max_distance: float = INF) -> Array[Node3D]:
	var targetable := _get_targetable(max_distance)
	var owner_node := get_parent() as Node3D
	targetable.sort_custom(func(a, b):
		return owner_node.global_position.distance_squared_to(a.global_position) < owner_node.global_position.distance_squared_to(b.global_position))
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

func _closest_of(nodes: Array[Node3D]) -> Node3D:
	if nodes.is_empty():
		return null
	var owner_node := get_parent() as Node3D
	var closest: Node3D = null
	var closest_dist := INF
	for node in nodes:
		var dist := owner_node.global_position.distance_squared_to(node.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = node
	return closest

func _random_of(nodes: Array[Node3D]) -> Node3D:
	if nodes.is_empty():
		return null
	return nodes[randi() % nodes.size()]
