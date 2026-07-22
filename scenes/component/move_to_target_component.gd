class_name MoveToTargetComponent
extends Node

@export var speed: float = 3.0
@export var is_flying: bool = false
@export var hold_height: float = 0.5
@export var gravity_enabled: bool = true

var target_position: Vector3 = Vector3.ZERO
# Written by StatusEffectComponent (1.0 = no slow, 0.6 = 40% slow).
var slow_multiplier: float = 1.0
var _bob_time: float = 0.0
var _faced_initially: bool = false

func _physics_process(delta: float) -> void:
	var body := get_parent() as CharacterBody3D
	if body == null or speed == 0.0:
		return

	var origin := body.global_position
	var direction := (target_position - origin)
	var effective_speed := speed * slow_multiplier

	# Enemies walk in a straight line to the fixed tower — face once at
	# spawn, toward the tower, and never recompute it again. Recomputing
	# facing every frame from post-move_and_slide() velocity used to make
	# enemies snap/spin whenever collision with another enemy deflected
	# their velocity for a frame.
	if not _faced_initially:
		_update_facing(body, direction)
		_faced_initially = true

	if is_flying:
		_bob_time += delta
		var target_y := hold_height + sin(_bob_time * 2.0) * 0.1
		body.velocity = Vector3(
			direction.x,
			(target_y - origin.y) * 5.0,
			direction.z
		).normalized() * effective_speed
		body.velocity.y = (target_y - origin.y) * 5.0
	else:
		var flat := Vector3(direction.x, 0.0, direction.z)
		if flat.length_squared() > 0.01:
			body.velocity.x = flat.normalized().x * effective_speed
			body.velocity.z = flat.normalized().z * effective_speed
		else:
			body.velocity.x = 0.0
			body.velocity.z = 0.0
		if gravity_enabled and not body.is_on_floor():
			body.velocity.y -= 9.8 * delta
		else:
			body.velocity.y = 0.0

	body.move_and_slide()

func _update_facing(body: CharacterBody3D, direction: Vector3) -> void:
	var flat := Vector3(direction.x, 0.0, direction.z)
	if flat.length_squared() < 0.001:
		return
	body.look_at(body.global_position + flat, Vector3.UP)
