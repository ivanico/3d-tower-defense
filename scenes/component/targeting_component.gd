class_name TargetingComponent
extends Node

@export var range: float = 8.0
@export var mode: int = Constants.TargetMode.CLOSEST

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

func get_target() -> Node3D:
	_enemies_in_range = _enemies_in_range.filter(func(e): return is_instance_valid(e))
	match mode:
		Constants.TargetMode.CLOSEST:
			return _closest_of(_enemies_in_range)
	return null

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
