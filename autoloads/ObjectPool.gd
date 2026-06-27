extends Node

# keyed by scene resource_path -> { available: Array, in_use: Array }
var _pools: Dictionary = {}
var _pool_root: Node

func _ready() -> void:
	_pool_root = Node.new()
	_pool_root.name = "PoolRoot"
	add_child(_pool_root)
	pass

func preload_pool(scene: PackedScene, count: int) -> void:
	var key := scene.resource_path
	if not _pools.has(key):	
		_pools[key] = { "available": [], "in_use": [] }
	for i in count:
		var node := scene.instantiate()
		_pool_root.add_child(node)
		node.visible = false
		_set_collision_shapes(node, false)
		_pools[key]["available"].append(node)

func acquire(scene: PackedScene) -> Node:
	var key := scene.resource_path
	if not _pools.has(key):
		_pools[key] = { "available": [], "in_use": [] }
	var node: Node
	if _pools[key]["available"].size() > 0:
		node = _pools[key]["available"].pop_back()
	else:
		node = scene.instantiate()
		_pool_root.add_child(node)
	node.visible = true
	_set_collision_shapes(node, true)
	_pools[key]["in_use"].append(node)
	return node

func release(node: Node) -> void:
	node.visible = false
	_set_collision_shapes(node, false)
	for key in _pools:
		var pool = _pools[key]
		if pool["in_use"].has(node):
			pool["in_use"].erase(node)
			pool["available"].append(node)
			return

func _set_collision_shapes(node: Node, enabled: bool) -> void:
	for child in node.get_children():
		if child is CollisionShape3D:
			child.disabled = not enabled
