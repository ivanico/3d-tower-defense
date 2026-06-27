class_name MoveToTargetComponent
extends Node

@export var speed: float = 3.0
@export var hold_height: float = 0.0
@export var gravity_enabled: bool = true

var target_position: Vector3 = Vector3.ZERO
var _bob_time: float = 0.0

func _physics_process(delta: float) -> void:
	var body := get_parent() as CharacterBody3D
	if body == null:
		return

	var origin := body.global_position
	var direction := (target_position - origin)

	if hold_height > 0.0:
		_bob_time += delta
		var target_y := hold_height + sin(_bob_time * 2.0) * 0.1
		body.velocity = Vector3(
			direction.x,
			(target_y - origin.y) * 5.0,
			direction.z
		).normalized() * speed
		body.velocity.y = (target_y - origin.y) * 5.0
	else:
		var flat := Vector3(direction.x, 0.0, direction.z)
		if flat.length_squared() > 0.01:
			body.velocity.x = flat.normalized().x * speed
			body.velocity.z = flat.normalized().z * speed
		else:
			body.velocity.x = 0.0
			body.velocity.z = 0.0
		if gravity_enabled and not body.is_on_floor():
			body.velocity.y -= 9.8 * delta
		else:
			body.velocity.y = 0.0

	body.move_and_slide()
	_update_facing(body, body.velocity)

func _update_facing(body: CharacterBody3D, direction: Vector3) -> void:
	var flat := Vector3(direction.x, 0.0, direction.z)
	if flat.length_squared() < 0.001:
		return
	body.look_at(body.global_position + flat, Vector3.UP)
